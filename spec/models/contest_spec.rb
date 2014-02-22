# == Schema Information
#
# Table name: contests
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  sport         :string(255)
#  contest_type  :string(255)
#  prize         :decimal(, )
#  entry_fee     :decimal(, )
#  contest_start :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  max_entries   :integer
#  contest_end   :datetime
#  entries_count :integer          default(0)
#

require 'spec_helper'

describe Contest do

  let(:contest) { create(:contest) }
  let(:user) { create(:user) }
  let(:lineup) { create(:lineup, user: user) }


  describe "Eligible contests for a user" do
    subject { Contest.upcoming(user) }

    before { create(:entry, contest: contest, lineup: lineup) }

    context "Another contest exists" do
      before { @unfilled_contest = create(:contest) }

      it { should == [@unfilled_contest] }
    end

    context "No other contest exists" do
      it {should be_empty}
    end

    context "contest expired" do
      before do
        c = create(:contest, contest_start: (Time.now - 1.day))
        create(:entry, contest: c, lineup: lineup)
      end

      it { should be_empty }
    end

    context "Tournament contests" do
      before { @tournament = create(:contest, contest_type: "Tournament") }

      it { should == [@tournament] }

      context "Entered 5 times" do
        before do
          5.times { create(:entry, contest: @tournament, lineup: lineup) }
        end
        it { should be_empty }
      end
    end

  end

  describe "Contest get filled" do
    let(:another_contest) { create(:contest, max_entries: 1) }
    subject { Contest.upcoming(user) }

    before do
      l = create(:lineup, user: create(:user))
      create(:entry, contest: another_contest, lineup: l)
    end

    it { should be_empty }
    
    it "should fail when entered too many times" do
      l = create(:lineup, user: create(:user))
      expect {create(:entry, contest: another_contest, lineup: l)}.to raise_error
    end
  end

  describe "Entering with lineup" do
    before { create(:entry, contest: contest, lineup: lineup) }

    it "should fail when entering same 50/50 contest twice" do
      expect { contest.enter(lineup) }.to raise_error
    end

    context "Another user is entering" do
      let(:another_user) { create(:user) }
      let(:another_lineup) { create(:lineup, user:another_user) }
    
      it "should enter successfully" do
        contest.enter(another_lineup).should be_present
      end

      context "Contest is already filled" do
        before do
          contest.max_entries = 1
          contest.save!
        end

        it "should fail when another user tries to enter" do
          expect { contest.enter(another_lineup) }.to raise_error
        end
      end

      context "Contest is about to be filled" do
        before do
          contest.max_entries = 2 
          contest.save!
        end

        it "should succeed and clone a new contest" do
          contest.enter(another_lineup).should be_present
          Contest.upcoming(user).count.should == 1
          (Contest.upcoming(user)[0].contest_start - contest.contest_start).should < 1
          Contest.upcoming(user)[0].max_entries.should == contest.max_entries
        end
      end

    end

  end

end
