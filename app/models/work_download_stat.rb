class WorkDownloadStat < ApplicationRecord
  def find_or_create(current_work)
    stat = WorkDownloadStat.find_by(work_uid: current_work.id)
    return stat if stat
    WorkDownloadStat.create(attributes_from_work(current_work))
  end

  def update(record)
    stats = find_or_create(record)
    total = stats.downloads + 1
    dates_arr = stats.date << Time.now.utc
    stats.update_attributes(downloads: total,
                            date: dates_arr) ## rewrites the array in db, could be made more efficient?
  end

  private

    def attributes_from_work(work)
      @work_uid = work.id
      @title = work.parent.title.first
      ## A Work title can be edited --> TO DO: update WorkDownloadStat if title changes
      @owner_id = ::User.find_by(email: work.depositor).id
      ## Get the `owner` id instead of `depositor`? Consequently:
      ## Update WorkDownloadStat owner_id if change of ownership?
      { work_uid: @work_uid, title: @title, owner_id: @owner_id }
    end
end
