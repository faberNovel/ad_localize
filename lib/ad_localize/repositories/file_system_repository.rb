module AdLocalize
  module Repositories
    class FileSystemRepository
      def create_directory(path:)
        path.mkpath unless path.directory?
      end

      def write(content:, path:)
        path.open("w") { |file| file.write content }
      end
    end
  end
end
