module Robots
  module CommandDSLEnabled
    def execute_command command
      begin
        self.instance_eval command.strip.downcase
      rescue Exception => e
        raise StandardError, "Command error on \"#{command.strip}\": #{e}"
      end
    end

    def execute_script input
      input.readlines.reject {|line| line.strip.empty?}.map {|c| self.execute_command c}
    end
  end
end