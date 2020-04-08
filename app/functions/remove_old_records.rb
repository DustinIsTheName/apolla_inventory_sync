class RemoveOldRecords
  def self.remove
    Order.delete_all("created_at < '#{1.day.ago}'")
    Refund.delete_all("created_at < '#{1.day.ago}'")
  end
end