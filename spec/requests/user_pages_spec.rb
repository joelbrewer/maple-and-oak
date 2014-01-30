require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "signup page" do
    before {visit new_user_registration_path }

    it { should have_content('Sign up') }

    describe "with valid information" do
      before { valid_signup "investor" }

      it "should create a new user" do
        expect { click_button "Sign up" }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button "Sign up" }
          let(:user) { User.find_by(email: 'user@example.com') }

          it { should have_link('Sign out') }
          it { should have_link('Profile') }
          it { should have_content('Select Plan') }
          it { should have_link('Messages') }
      end
    end
  end

  describe "profile page" do
    let(:user) {FactoryGirl.create(:user) }

    let(:card) do 
    { :number => '4242424242424242', :exp_month => '11', :exp_year => '2020' }
    end

    before do
      sign_in user
      visit profile_path
    end

    describe "user information" do

      it { should have_content(user.email) }
      it { should have_content(user.user_type.capitalize) }
      it { should have_content(user.full_name) }

      describe "if user has a subscription" do
        before do 
          FactoryGirl.create(:plan_with_subscription, user: user)
          visit profile_path
        end

        it { should have_content(user.subscription.plan.name) }

      end
    end


    describe "when user has created a project"
      before do
        FactoryGirl.create(:project, user: user)
        FactoryGirl.create(:project, user: user, title: "Another Project")
        visit profile_path
      end

      it { should have_content("Projects") }

      it "should render the user's projects" do
        user.projects.each do |project|
          expect(page).to have_content(project.title)
        end
      end


    describe "when user does not have available projects remaining" do
      before do
        FactoryGirl.create(:plan_with_subscription, user: user, user_project_limit: '0')
        visit profile_path
      end

      describe "should not have a link to create a new project" do
        it { should_not have_link('Add project') }
      end
    end

    describe "when user has available projects remaining" do
      before do
        FactoryGirl.create(:plan_with_subscription, user: user, user_project_limit: '10')
        visit profile_path
      end

      describe "should have a link to create a new project" do
        it { should have_link('Add project') }

        describe "clicking add project link"  do
          before { click_link "Add project" }
          it "should direct to new project page" do
            current_path.should == new_project_path
          end
        end
      end
    end
  end
end