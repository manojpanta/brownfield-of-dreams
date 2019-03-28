require 'rails_helper'

describe 'An admin user can change the position of a video in a playlist', :js do
  it 'by dragging it and saving the new position' do
    admin = create(:user, role: 1)
    tutorial = create(:tutorial)
    create(:video, title: 'video_1', tutorial: tutorial)
    create(:video, title: 'video_2', tutorial: tutorial)
    create(:video, title: 'video_3', tutorial: tutorial)
    create(:video, title: 'video_4', tutorial: tutorial)
    create(:video, title: 'video_5', tutorial: tutorial)

    expect(Video.find_by(title: 'video_1').position).to eq(0)
    expect(Video.find_by(title: 'video_5').position).to eq(0)
    login_as(admin)
    visit(edit_admin_tutorial_path(tutorial))

    click_link('Save Video Order')
    sleep(0.1)
    expect(Video.find_by(title: 'video_1').position).to eq(1)
    expect(Video.find_by(title: 'video_5').position).to eq(5)
  end
end
