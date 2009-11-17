module Redcar
  class ApplicationSWT
    class Menu
      module BindingTranslator
        MODIFIERS = %w(Cmd Ctrl Alt Shift)
        
        def self.platform_key_string(key_specifier)
          if key_specifier.is_a?(Hash)
            key_string = key_specifier[Core.platform]
          else
            key_string = key_specifier
          end
          key_string
        end

        def self.key(key_string)
          value = 0
          MODIFIERS.each do |modifier|
            if key_string =~ /\b#{modifier}\b/
              value += modifier_values[modifier]
            end
          end
          value += key_string[-1]
        end
        
        private
        
        def self.modifier_values
          {
            "Cmd" => Swt::SWT::COMMAND,
            "Ctrl" => Swt::SWT::CTRL,
            "Alt" => Swt::SWT::ALT,
            "Shift" => Swt::SWT::SHIFT,
          }
        end
      end
    end
  end
end
