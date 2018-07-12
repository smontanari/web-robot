require 'stringio'
require 'spec_helper'

module Robots
  describe CommandDSLEnabled do
    let(:dummy_robot) {double('robot')}

    before(:each) do
      dummy_robot.extend CommandDSLEnabled
    end

    it 'evaluates a single text command' do
      expect(dummy_robot).to receive(:instance_eval).with 'do_something 123, test_param'

      dummy_robot.execute_command 'DO_SOMETHING 123, TEST_PARAM'
    end

    it 'traps error on command evaluation and writes to stderr' do
      $stderr = StringIO.new
      allow(dummy_robot).to receive(:instance_eval).and_raise 'Command failure'

      expect { dummy_robot.execute_command 'DO_SOMETHING_WRONG' }.to raise_error 'Command error on "DO_SOMETHING_WRONG": Command failure'
    end

    it 'reads and evaluates multiple commands from an input text stream' do
      input = StringIO.new <<-EOF
        DO_ONE_THING

        DO_ANOTHER_THING

      EOF

      ['do_one_thing', 'do_another_thing'].each do |command|
        expect(dummy_robot).to receive(:instance_eval).with(command).ordered.and_return "#{command}_output"
      end

      expect(dummy_robot.execute_script input).to eq ['do_one_thing_output','do_another_thing_output']
    end
  end
end
