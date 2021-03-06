require 'rails_helper'

describe "User abilities" do

  subject(:ability)   { Ability.new(user) }
  let(:circle)        { create(:circle) }
  let(:working_group) { create(:working_group, circle: circle) }
  let(:task)          { create(:task, working_group: working_group) }
  let(:project)       { create(:project, working_group: working_group) }

  context "as a guest" do
    let(:user){ nil }
    it { is_expected.not_to be_able_to(:read, circle) }
    it { is_expected.to     be_able_to(:create, Circle.new) }
    it { is_expected.not_to be_able_to(:update, circle) }
    it { is_expected.not_to be_able_to(:destroy, circle) }
    it { is_expected.not_to be_able_to(:complete, task) }
  end

  context "as circle admin" do
    let(:user){ create(:circle_admin) }
    let(:circle) { user.circles.first }

    it { is_expected.to     be_able_to(:read, circle) }
    it { is_expected.to     be_able_to(:create, Circle.new) }
    it { is_expected.to     be_able_to(:update, circle) }
    it { is_expected.to     be_able_to(:destroy, circle) }

    it { is_expected.to     be_able_to(:read, working_group) }
    it { is_expected.to     be_able_to(:create, WorkingGroup.new(circle: circle)) }
    it { is_expected.to     be_able_to(:update, working_group) }
    it { is_expected.to     be_able_to(:destroy, working_group) }

    it { is_expected.to     be_able_to(:read, task) }
    it { is_expected.to     be_able_to(:create, Task.new(working_group: working_group)) }
    it { is_expected.to     be_able_to(:update, task) }
    it { is_expected.to     be_able_to(:destroy, task) }
    it { is_expected.to     be_able_to(:volunteer, task) }
    it { is_expected.to     be_able_to(:complete, task) }
    it { is_expected.to     be_able_to(:invite_to, task) }
    it { is_expected.to     be_able_to(:assign, task) }
    it { is_expected.to     be_able_to(:unassign, task) }

    it { is_expected.to     be_able_to(:read, project) }
    it { is_expected.to     be_able_to(:update, project) }
    it { is_expected.to     be_able_to(:delete, project) }

    it { is_expected.to     be_able_to(:manage, working_group) }
    it { is_expected.to     be_able_to(:create_project, working_group.circle) }

    context "project in private working group" do
      let(:working_group) { create(:private_working_group, circle: circle) }
      let(:project) { create(:project, working_group: working_group) }
      it { is_expected.to be_able_to(:read, project) }
      it { is_expected.to be_able_to(:update, project) }
      it { is_expected.to be_able_to(:delete, project) }
    end

  end

  context "as member of a circle" do
    let(:user) { create(:circle_volunteer) }
    let(:circle) { user.circles.first }

    it { is_expected.to     be_able_to(:read, circle) }
    it { is_expected.to     be_able_to(:create, Circle.new) }
    it { is_expected.not_to be_able_to(:update, circle) }
    it { is_expected.not_to be_able_to(:destroy, circle) }

    it { is_expected.to     be_able_to(:read, working_group) }
    it { is_expected.not_to be_able_to(:create, WorkingGroup.new(circle: circle)) }
    it { is_expected.not_to be_able_to(:update, working_group) }
    it { is_expected.not_to be_able_to(:destroy, working_group) }

    it { is_expected.to     be_able_to(:read, task) }
    it { is_expected.not_to be_able_to(:create, Task.new(working_group: working_group)) }
    it { is_expected.not_to be_able_to(:update, task) }
    it { is_expected.not_to be_able_to(:destroy, task) }
    it { is_expected.to     be_able_to(:volunteer, task) }
    it { is_expected.not_to be_able_to(:complete, task) }
    it { is_expected.not_to be_able_to(:invite_to, task) }
    it { is_expected.not_to be_able_to(:assign, task) }
    it { is_expected.not_to be_able_to(:unassign, task) }

    it { is_expected.to     be_able_to(:read, project) }
    it { is_expected.not_to be_able_to(:update, project) }
    it { is_expected.not_to be_able_to(:delete, project) }
  end

  context "as admin of working group" do
    let!(:user) { create(:working_group_admin) }
    let(:working_group) { user.working_groups.first }
    let(:project) { create(:project, working_group: working_group) }

    before do
      # a circle and role are required here because the user activity status is stored on the circle role
      create(:circle_role_volunteer, circle: working_group.circle, user: user)
    end

    it { is_expected.to     be_able_to(:read, project) }
    it { is_expected.to     be_able_to(:manage, project) }
    it { is_expected.to     be_able_to(:invite_to, task) }
    it { is_expected.to     be_able_to(:assign, task) }
    it { is_expected.to     be_able_to(:unassign, task) }

    context 'private working group' do

      before do
        @project = create(:project, working_group: working_group)
        @project.working_group.update_attribute(:is_private, true)
      end

      context "own" do
        it { is_expected.to be_able_to(:read, @project) }
        it { is_expected.to be_able_to(:update, @project) }
        it { is_expected.to be_able_to(:delete, @project) }
      end

      context "someone else's" do
        before { user.working_group_roles.destroy_all }
        it { is_expected.not_to be_able_to(:read, @project) }
        it { is_expected.not_to be_able_to(:update, @project) }
        it { is_expected.not_to be_able_to(:delete, @project) }
      end
    end
  end


  context "as working group member" do

    let!(:user) { create(:working_group_member) }
    let(:working_group) { user.working_groups.first }
    let(:project) { create(:project, working_group: working_group) }

    before do
      @project = create(:project, working_group: working_group)
    end

    it { is_expected.not_to be_able_to(:manage, @project) }
    it { is_expected.not_to be_able_to(:invite_to, task) }
    it { is_expected.not_to be_able_to(:assign, task) }
    it { is_expected.not_to be_able_to(:unassign, task) }

    context 'private working group' do

      before do
        @project.working_group.update_attribute(:is_private, true)
      end

      context "own" do
        it { is_expected.to be_able_to(:read, @project) }
        it { is_expected.not_to be_able_to(:update, @project) }
        it { is_expected.not_to be_able_to(:delete, @project) }
      end

      context "someone else's" do
        before { user.working_group_roles.destroy_all }
        it { is_expected.not_to be_able_to(:read, @project) }
        it { is_expected.not_to be_able_to(:update, @project) }
        it { is_expected.not_to be_able_to(:delete, @project) }
      end
    end
  end

end
