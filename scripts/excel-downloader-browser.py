#!/usr/bin/env python3
#
# This script can be used with ad_localize like this :
# 
# XLSX_FILE=$(./excel-downloader-browser.py <sharepoint share url>)
# ad_localize --excel-file $XLSX_FILE
#

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import webbrowser
from pathlib import Path
from urllib.parse import urlparse, unquote, quote
from urllib.request import Request, urlopen


def run(cmd):
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def get_graph_token():
    try:
        return run([
            "az",
            "account",
            "get-access-token",
            "--resource-type",
            "ms-graph",
            "--query",
            "accessToken",
            "-o",
            "tsv",
        ])
    except subprocess.CalledProcessError:
        print(
            "Impossible de récupérer un token Graph. "
            "Exécutez 'az login'.",
            file=sys.stderr,
        )
        sys.exit(1)


def graph_get(url, token):
    req = Request(
        url,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/json",
        },
    )

    with urlopen(req) as response:
        return json.loads(response.read().decode("utf-8"))


def graph_redirect(url, token):
    req = Request(
        url,
        headers={
            "Authorization": f"Bearer {token}",
        },
        method="GET",
    )

    import urllib.request

    class RedirectBlocker(urllib.request.HTTPRedirectHandler):
        def redirect_request(
            self,
            req,
            fp,
            code,
            msg,
            headers,
            newurl,
        ):
            return None

    opener = urllib.request.build_opener(RedirectBlocker)

    try:
        opener.open(req)
        raise RuntimeError("Aucune redirection reçue")

    except Exception as e:
        if hasattr(e, "headers"):
            location = e.headers.get("Location")
            if location:
                return location
        raise

def graph_encode_path(path):
    return quote(path, safe="/")

def parse_sharepoint_url(url):
    u = urlparse(url)

    path = unquote(u.path)

    parts = [p for p in path.split("/") if p]

    site_index = parts.index("sites")

    site_name = parts[site_index + 1]

    library_name = parts[site_index + 2]

    file_segments = parts[site_index + 3:]

    file_path = "/".join(file_segments)

    return {
        "hostname": u.hostname,
        "site_name": site_name,
        "site_path": f"/sites/{site_name}",
        "library_name": library_name,
        "file_path": file_path,
        "filename": os.path.basename(file_path),
    }


def snapshot_downloads(downloads_dir):
    snapshot = {}

    for p in Path(downloads_dir).iterdir():
        if not p.is_file():
            continue

        stat = p.stat()

        snapshot[str(p)] = {
            "size": stat.st_size,
            "mtime_ns": stat.st_mtime_ns,
        }

    return snapshot


def wait_for_download(
    downloads_dir,
    filename,
    baseline,
    timeout=180,
):
    stem = Path(filename).stem
    suffix = Path(filename).suffix

    pattern = re.compile(
        rf"^{re.escape(stem)}(?: \((\d+)\))?{re.escape(suffix)}$",
        re.IGNORECASE,
    )

    partial_suffixes = (
        ".crdownload",
        ".download",
        ".part",
        ".partial",
        ".tmp",
    )

    deadline = time.monotonic() + timeout

    stability = {}

    while time.monotonic() < deadline:

        candidates = []

        for entry in Path(downloads_dir).iterdir():

            if not entry.is_file():
                continue

            lower = entry.name.lower()

            if lower.endswith(partial_suffixes):
                continue

            if not pattern.fullmatch(entry.name):
                continue

            stat = entry.stat()

            old = baseline.get(str(entry))

            changed = (
                old is None
                or old["size"] != stat.st_size
                or old["mtime_ns"] != stat.st_mtime_ns
            )

            if not changed:
                continue

            candidates.append(
                {
                    "path": str(entry),
                    "size": stat.st_size,
                    "mtime_ns": stat.st_mtime_ns,
                }
            )

        if candidates:

            candidate = max(
                candidates,
                key=lambda x: x["mtime_ns"],
            )

            path = candidate["path"]
            size = candidate["size"]

            previous = stability.get(path)

            if previous and previous["size"] == size:
                count = previous["count"] + 1
            else:
                count = 1

            stability = {
                path: {
                    "size": size,
                    "count": count,
                }
            }

            if size > 0 and count >= 3:
                return path

        else:
            stability = {}

        time.sleep(1)

    raise TimeoutError(
        f"Téléchargement non détecté pour {filename}"
    )


def main():

    parser = argparse.ArgumentParser(
        description="Téléchargement SharePoint via Graph + navigateur"
    )

    parser.add_argument(
        "sharepoint_url",
        help="URL SharePoint du fichier",
    )

    parser.add_argument(
        "-o",
        "--output",
        help="Fichier de sortie. Si absent, un fichier temporaire est utilisé.",
    )

    args = parser.parse_args()

    sharepoint_url = args.sharepoint_url
    output_file = args.output

    token = get_graph_token()

    info = parse_sharepoint_url(sharepoint_url)

    hostname = info["hostname"]
    site_path = info["site_path"]
    file_path = info["file_path"]
    file_name = info["filename"]

    print("HOSTNAME :", hostname, file=sys.stderr)
    print("SITE_PATH :", site_path, file=sys.stderr)
    print("FILE_PATH :", file_path, file=sys.stderr)
    print("FILE_NAME :", file_name, file=sys.stderr)

    print("Recherche du Site ID...", file=sys.stderr)

    site = graph_get(
        f"https://graph.microsoft.com/v1.0/sites/{hostname}:{site_path}",
        token,
    )

    site_id = site["id"]

    print("SITE_ID :", site_id, file=sys.stderr)

    drives = graph_get(
        f"https://graph.microsoft.com/v1.0/sites/{site_id}/drives",
        token,
    )

    drive_id = None

    for drive in drives.get("value", []):
        weburl = drive.get("webUrl", "").lower()

        if "shared%20documents" in weburl:
            drive_id = drive["id"]
            break

    if not drive_id:
        drive_id = drives["value"][0]["id"]

    print("DRIVE_ID :", drive_id, file=sys.stderr)

    downloads_dir = os.environ.get(
        "DOWNLOADS_DIR",
        str(Path.home() / "Downloads"),
    )

    baseline = snapshot_downloads(downloads_dir)

    encoded_file_path = graph_encode_path(file_path)

    download_url = (
        f"https://graph.microsoft.com/v1.0/"
        f"drives/{drive_id}"
        f"/root:/{encoded_file_path}:/content"
    )

    redirect_url = graph_redirect(
        download_url,
        token,
    )

    parsed_redirect = urlparse(redirect_url)

    if parsed_redirect.hostname.lower() != hostname.lower():
        raise RuntimeError(
            "Hostname de redirection inattendu"
        )

    print("Ouverture navigateur...", file=sys.stderr)

    webbrowser.open(redirect_url)

    downloaded_file = wait_for_download(
        downloads_dir,
        file_name,
        baseline,
        timeout=int(
            os.environ.get(
                "DOWNLOAD_TIMEOUT",
                "180",
            )
        ),
    )

    if output_file:

        output_file = os.path.abspath(output_file)

        parent_dir = os.path.dirname(output_file)

        if parent_dir:
            os.makedirs(
                parent_dir,
                exist_ok=True,
            )

        final_file = output_file

    else:

        tmp_dir = tempfile.mkdtemp(
            prefix="sharepoint-download-"
        )

        final_file = os.path.join(
            tmp_dir,
            file_name,
        )

    shutil.move(
        downloaded_file,
        final_file,
    )

    size = os.path.getsize(final_file)

    if size == 0:
        raise RuntimeError(
            "Le fichier téléchargé est vide"
        )

    print(file=sys.stderr)
    print("Téléchargement réussi", file=sys.stderr)
    print("Source  :", downloaded_file, file=sys.stderr)
    print("Fichier :", final_file, file=sys.stderr)
    print("Taille  :", size, "octets", file=sys.stderr)
    print(final_file)


if __name__ == "__main__":
    main()