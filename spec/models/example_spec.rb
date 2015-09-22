require 'rails_helper'

describe 'Specs' do
  it 'should look like this' do
    expect(true).to eq(true)
  end

  it 'can create associations for the initial schema' do
    volunteer1 = log 'vol1', Volunteer.create!(first_name: 'volunteer1')
    volunteer2 = log 'vol2', Volunteer.create!(first_name: 'volunteer2')

    locations  = log 'locations', 2.times.map { |i| Location.create!(name: "Location #{i}") }

    skills     = log 'skills', 3.times.map{ |i| Task::Skill.create!(name: "Skill #{i}")}

    # Volunteer creates a circle
    circle     = log 'circle', Circle.create(name: 'munich rocks', location: locations[0])
    group      = log 'group',  circle.working_groups.create!(name: 'owners', volunteers: [ volunteer1 ])

    # Volunteer creates a discussion
    discussion = log 'discussion', group.discussions.create!(name: 'should we foobar?', watchers: [ volunteer1 ])
    message    = log 'message',    discussion.messages.create!(volunteer: volunteer1, content: 'foo bar')

    # Volunteer creates a task from a discussion
    task       = log 'task', discussion.tasks.create!(name: 'foobar', working_group: group)
    task.organizers << volunteer1
    expect(task.organizers).to eq([volunteer1])
    log 'task organizers', task.organizers.map(&:first_name)

    # Task is assigned
    task.volunteers << volunteer2
    expect(task.volunteers).to eq([volunteer2])
    log 'task volunteers', task.volunteers.map(&:first_name)

    # Task skills assigned
    task.skills = skills
    expect(task.skills).to eq(skills)
    expect(task.skill_assignments.count).to eq(3)
    log 'task skills', task.skills.map(&:name)

    # Task location assigned
    task.location_assignments.create location: locations[0], primary: true
    task.location_assignments.create location: locations[1]
    expect(task.locations).to eq(locations)
    log 'task locations', task.locations.map(&:name)

  end

  FMT = "%20s: %s"
  def log tag, obj
    Rails.logger.info FMT % [tag.to_s, obj.inspect]
    obj
  end
end
