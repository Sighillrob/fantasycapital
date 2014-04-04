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
#  contestdate   :date
#

require 'spec_helper'
require 'time'
describe Contest do

  let(:now) { Time.parse("2014-03-20 17:51:27 -0700")}
  let(:todaydate) { now.to_date }

  let(:user) { create(:user) }
  let(:lineup) { create(:lineup, user: user) }
  let!(:game) {create(:game_score, playdate:"2014-03-21", scheduledstart: now + 18.hours)}
  let(:contest) { create(:contest, contestdate: game.playdate) }

  describe "User has entered one contest" do
    subject {
      Contest.in_range(user, now.to_date, now.to_date+1).eligible(user, now)
    }

    # created one entry, thus
    before { create(:entry, contest: contest, lineup: lineup) }

    context "Another contest exists" do
      before {
        @unfilled_contest = create(:contest, contestdate: game.playdate)
      }

      it "User should be eligible to enter the unfilled one" do
        should == [@unfilled_contest]
      end
    end

    context "No other contest exists" do
      it "User is eligible for nothing" do
        should be_empty
      end
    end

    context "contest expired" do
      before do
        c = create(:contest)
        create(:entry, contest: c, lineup: lineup)
      end

      it { should be_empty }
    end

    context "Tournament contests" do
      before { @tournament = create(:contest, contest_type: "Tournament", contestdate: game.playdate) }

      it "User should be eligible to enter it" do
        should == [@tournament]
      end

      context "Entered 5 times" do
        before do
          5.times { create(:entry, contest: @tournament, lineup: lineup) }
        end
        it "is ineligible for entry a 6th time" do
          should be_empty
        end
      end
    end

  end

  describe "Contest that only allows one entry, and has one entry" do
    let(:another_contest) { create(:contest, max_entries: 1, contestdate: game.playdate) }

    subject {
      Contest.in_range(user, todaydate, todaydate+1).eligible(user, now)
    }

    before do
      l = create(:lineup, user: create(:user))
      create(:entry, contest: another_contest, lineup: l)
    end

    it "won't be available for entry" do
      should == []
    end
    
    it "will fail when entered again" do
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
          upcoming_cont = Contest.in_range(user, todaydate, todaydate+1).eligible(user, now)
          upcoming_cont.count.should == 1

          (upcoming_cont[0].contest_start - contest.contest_start).should < 1
          upcoming_cont[0].max_entries.should == contest.max_entries
        end
      end

    end

  end

end
