class Authentication::VolunteerRegistration < Mutations::Command
  required do
    model :identity, class: Volunteer::Identity, new_records: true
  end

  def execute
    location = Location.location_from(identity.location)
    circle = Circle.find(identity.circle_id)
    identity.volunteer = Volunteer.create!(first_name: identity.first_name, last_name: identity.last_name, location: location, circle: circle)
  end
end