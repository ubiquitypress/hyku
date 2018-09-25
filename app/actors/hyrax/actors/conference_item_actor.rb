module Hyrax
  module Actors
    class ConferenceItemActor < Hyrax::Actors::BaseActor

      def create(env)
        puts "PURPLE #{env.attributes.inspect}"
        super
      end

      def update(env)
        puts "PINKO #{env.attributes.inspect}"
        super
      end
    end
  end
end
