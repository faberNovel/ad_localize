#!/usr/bin/env python3
#
# Download an Excel file from a SharePoint share link by using the user browser session.
# Accepts long share links (/:x:/r/...?d=w<id>) and Excel Online URLs (Doc.aspx?sourcedoc={id}).
# Short share links (/:x:/s/...) must first be opened in the browser to get the Excel Online URL.
#
# This script can be used with ad_localize like this :
#
# XLSX_FILE=$(./excel-downloader-browser.py <sharepoint share url>)
# ad_localize --excel-file $XLSX_FILE
#

import argparse
import os
import re
import shutil
import sys
import tempfile
import time
import uuid
import webbrowser
from pathlib import Path
from urllib.parse import parse_qsl, unquote, urlencode, urlparse, urlunparse

EXCEL_SUFFIX = ".xlsx"
SITE_PREFIXES = ("sites", "teams", "personal")
STABLE_CHECKS = 3


def file_unique_id(query):
    # Long share links carry the file id as d=w<32 hex>, Excel Online URLs as sourcedoc={guid}
    raw = query.get("d", "").removeprefix("w") or query.get("sourcedoc") or query.get("UniqueId", "")
    hex_id = re.sub(r"[{}\-]", "", raw).lower()

    if not re.fullmatch(r"[0-9a-f]{32}", hex_id):
        return None

    return str(uuid.UUID(hex_id))


def site_path(path):
    parts = [p for p in unquote(path).split("/") if p]
    index = next((i for i, p in enumerate(parts) if p in SITE_PREFIXES), None)

    if index is None or index + 1 >= len(parts):
        return None

    return "/" + "/".join(parts[index:index + 2])


def download_url(share_url):
    url = urlparse(share_url)

    if url.scheme != "https" or not url.hostname:
        raise ValueError(f"URL de partage https attendue : {share_url}")

    unique_id = file_unique_id(dict(parse_qsl(url.query)))
    site = site_path(url.path)

    if not unique_id or not site:
        raise ValueError(
            "Identifiant du fichier introuvable dans le lien. "
            "Pour un lien court (/:x:/s/...), ouvrez-le dans le navigateur "
            "et relancez le script avec l'URL affichée dans la barre d'adresse."
        )

    query = urlencode({"UniqueId": unique_id})

    return urlunparse(("https", url.netloc, f"{site}/_layouts/15/download.aspx", "", query, ""))


def snapshot(downloads_dir):
    return {
        p.name: p.stat().st_mtime_ns
        for p in Path(downloads_dir).iterdir()
        if p.is_file()
    }


def wait_for_download(downloads_dir, baseline, timeout):
    deadline = time.monotonic() + timeout
    last_seen = None
    stable_count = 0

    while time.monotonic() < deadline:
        # Browsers write to a temporary name (.crdownload, .part, ...) and rename at the end,
        # so only completed files carry the .xlsx suffix
        candidates = [
            p for p in Path(downloads_dir).iterdir()
            if p.is_file()
            and p.suffix.lower() == EXCEL_SUFFIX
            and baseline.get(p.name) != p.stat().st_mtime_ns
        ]

        if candidates:
            newest = max(candidates, key=lambda p: p.stat().st_mtime_ns)
            current = (newest, newest.stat().st_size)

            stable_count = stable_count + 1 if current == last_seen else 1
            last_seen = current

            if current[1] > 0 and stable_count >= STABLE_CHECKS:
                return newest

        time.sleep(1)

    raise TimeoutError(f"Aucun fichier {EXCEL_SUFFIX} téléchargé dans {downloads_dir}")


def main():
    parser = argparse.ArgumentParser(
        description="Téléchargement d'un fichier Excel SharePoint via la session du navigateur"
    )
    parser.add_argument("share_url", help="Lien de partage SharePoint du fichier")
    parser.add_argument(
        "-o",
        "--output",
        help="Fichier de sortie. Si absent, un fichier temporaire est utilisé.",
    )
    args = parser.parse_args()

    downloads_dir = os.environ.get("DOWNLOADS_DIR", str(Path.home() / "Downloads"))
    timeout = int(os.environ.get("DOWNLOAD_TIMEOUT", "180"))

    try:
        url = download_url(args.share_url)
        baseline = snapshot(downloads_dir)

        print("Ouverture navigateur...", file=sys.stderr)
        webbrowser.open(url)

        downloaded_file = wait_for_download(downloads_dir, baseline, timeout)
    except (ValueError, TimeoutError, OSError) as e:
        print(f"Erreur : {e}", file=sys.stderr)
        sys.exit(1)

    if args.output:
        final_file = Path(args.output).resolve()
        final_file.parent.mkdir(parents=True, exist_ok=True)
    else:
        final_file = Path(tempfile.mkdtemp(prefix="sharepoint-download-")) / downloaded_file.name

    shutil.move(downloaded_file, final_file)

    print("Téléchargement réussi :", final_file, file=sys.stderr)
    print(final_file)


if __name__ == "__main__":
    main()
