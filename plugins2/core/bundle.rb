
module Redcar
  # This class manages Textmate bundles. On Redcar startup
  # it will scan for and load bundle information for all bundles
  # in Redcar::App.root_path + "/textmate/Bundles".
  class Bundle
    extend FreeBASE::StandardPlugin
    
    def self.load(plugin) #:nodoc:
      load_bundles(Redcar::App.root_path + "/textmate/Bundles/")
      plugin.transition(FreeBASE::LOADED)
    end
    
    def self.load_bundles(dir) #:nodoc:
      Dir.glob(dir+"*").each do |bdir|
        if bdir =~ /\/([^\/]*)\.tmbundle/
          name = $1
          Bundle.new name, bdir
        end
      end
    end
    
    # Translates a Textmate key equivalent into a Redcar
    # keybinding. 
    def self.translate_key_equivalent(keyeq)
      if keyeq
        key_str      = keyeq.at(-1)
#        p key_str
        case key_str
        when "\n"
          letter = "Return"
        else
          letter = key_str.gsub("\e", "Escape")
        end
        modifier_str = keyeq.strip[0..-2]
        modifiers = modifier_str.split("").map do |modchar|
          case modchar
          when "^" # TM: Control
            [2, "Super"]
          when "~" # TM: Option
            [3, "Alt"]
          when "@" # TM: Command
            [1, "Ctrl"]
          when "$"
            [4, "Shift"]
          else
            puts "unknown key_equivalent: #{keyeq}"
            return nil
          end
        end.sort_by {|a| a[0]}.map{|a| a[1]}
        if modifiers.empty?
          letter
        else
          modifiers.join("+") + "+" + letter
        end
      end
    end
    
    # Return an array of the names of all bundles loaded.
    def self.names
      bus("/redcar/bundles/").children.map &:name
    end
    
    # Get the Bundle with the given name.
    def self.get(name)
      if slot = bus("/redcar/bundles/#{name}", true)
        slot.data
      end
    end
    
    # Do not call this directly. Retrieve a loaded bundle
    # with:
    #
    #   Redcar::Bundle.get('Ruby')
    def initialize(name, dir)
      @name = name
      @dir  = dir
      bus("/redcar/bundles/#{name}").data = self
    end
    
    # A hash of all Bundle preferences.
    def preferences
      @preferences ||= load_preferences
    end
    
    def load_preferences #:nodoc:
      prefs = {}
      Dir.glob(@dir+"/Preferences/*").each do |preffile|
        xml = IO.readlines(preffile).join
        pref = Redcar::Plist.plist_from_xml(xml)[0]
        prefs[pref["name"]] = pref
      end
      prefs
    end
    
    # A array of this bundle's snippets. Snippets are cached 
    def snippets
      @snippets ||= load_snippets
    end
    
    def load_snippets #:nodoc:
      unless Redcar::EditView.cache_dir
        raise "called SnippetInserter.load_snippets without a cache_dir"
      end
      cache_dir = Redcar::EditView.cache_dir
      if File.exist?(cache_dir + "snippets/#{@name}.dump")
        str = File.read(cache_dir + "snippets/#{@name}.dump")
        snippets = Marshal.load(str)
      else
        snippets = []
        Dir.glob(@dir+"/Snippets/*").each do |snipfile|
          xml = IO.readlines(snipfile).join
          snip = Redcar::Plist.plist_from_xml(xml)[0]
          snippets << snip
        end
        File.open(cache_dir + "snippets/#{@name}.dump", "w") do |fout|
          fout.puts Marshal.dump(snippets)
        end
      end
      snippets
    end
  end
end
