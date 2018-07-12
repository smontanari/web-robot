module Robots
  module Matchers
    def self.define_struct_matcher matcher_name, struct_clazz
      RSpec::Matchers.define matcher_name do
        match do |actual|
          actual.class == struct_clazz and (@predicates || []).all? { |predicate| predicate.call(actual) }
        end

        struct_clazz.members.each do |member|
          chain "with_#{member}".to_sym do |value|
            (@predicates || []) << lambda {|obj| obj.send(member) == value}
          end
        end
      end
    end
  end
end
