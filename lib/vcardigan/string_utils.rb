module VCardigan
  class StringUtils
    def self.escape(string)
      string.to_s.gsub(/[\\,;]/, "\\\0").gsub(/\r?\n/, "\\n")
    end

    UNESCAPES = {
      'a' => "\x07", 'b' => "\x08", 't' => "\x09",
      'n' => "\x0a", 'v' => "\x0b", 'f' => "\x0c",
      'r' => "\x0d", 'e' => "\x1b", '\\' => '\\',
      "\"" => "\x22", ';' => ';', ',' => ','
    }

    def self.unescape(str)
      # Escape all the things
      str.gsub(/\\(?:([#{UNESCAPES.keys.join}])|u([\da-fA-F]{4}))|0?x([\da-fA-F]{2})/) {
        if $1
          UNESCAPES[$1] # escape characters
        elsif $2 # escape \u0000 unicode
          ["#$2".hex].pack('U*')
        elsif $3 # escape \0xff or \xff
          [$3].pack('H2')
        end
      }
    end
  end
end
