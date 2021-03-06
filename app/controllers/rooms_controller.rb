class RoomsController < ApplicationController
  # Mark this as a JSONAPI controller, associating with the given resource
  jsonapi resource: RoomResource

  # Reference a strong resource payload defined in
  # config/initializers/strong_resources.rb
  strong_resource :room
  # Run strong parameter validation for these actions.
  # Invalid keys will be dropped.
  # Invalid value types will log or raise based on the configuration
  # ActionController::Parameters.action_on_invalid_parameters
  # before_action :apply_strong_params, only: %i[create update]

  def show
    room = Room.find(params[:id])

    ActionCable.server.broadcast('queue', songs_for(room))

    raise JsonapiCompliable::Errors::RecordNotFound unless room
    render_jsonapi(room, scope: false)
  end

  private

  def songs_for(room)
    JSONAPI::Serializable::Renderer
      .new
      .render(room.songs, class: { Song: SerializableSong })
  end
end
