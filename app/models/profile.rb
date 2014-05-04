class Profile < ActiveRecord::Base

  monetize :assets_liquid_cents, :allow_nil => true
  monetize :assets_marketable_securities_cents, :allow_nil => true
  monetize :assets_real_estate_cents, :allow_nil => true
  monetize :assets_personal_cents, :allow_nil => true
  monetize :assets_notes_receivable_cents, :allow_nil => true
  monetize :assets_business_holdings_cents, :allow_nil => true
  monetize :assets_total_cents, :allow_nil => true
  monetize :liabilities_notes_payable_cents, :allow_nil => true
  monetize :liabilities_accounts_payable_cents, :allow_nil => true
  monetize :liabilities_auto_loans_cents, :allow_nil => true
  monetize :liabilities_mortgage_cents, :allow_nil => true
  monetize :liabilities_other_cents, :allow_nil => true
  monetize :liabilities_total_cents, :allow_nil => true
  monetize :net_worth_cents, :allow_nil => true

  USER_EXPERIENCE_VALUES =
    [
      ['<2', '<2'],
      ['2-5', '2-5'],
      ['5-7', '5-7'],
      ['7-10', '7-10'],
      ['10+', '10+']
    ]

  REQUIRED_FIELDS_FOR_PUBLISHING = ["state", "city", "company_name", "contact_email_address",
                     "contact_phone_number", "short_description", "long_description", "category", "sub_category"]

  INVESTMENT_AMOUNT_VALUES =
    [ 
      ['less than 25,000', 'less than 25,000'],
      ['25,000-50,000', '25,000-50,000'],
      ['50,000-75,000', '50,000-75,000'],
      ['75,000-125,000', '75,000-125,000'],
      ['125,000-150,000', '125,000-150,000'],
      ['150,000-250,000', '150,000-250,000'],
      ['more than 250,000', 'more than 250,000']
    ]

  SEAT_NUMBER_VALUES =
    [
      ['0-25', '0-25'],
      ['25-50', '25-50'],
      ['50-75', '50-75'],
      ['75-100', '75-100'],
      ['100-150', '100-150'],
      ['150+', '150+']
    ]

  belongs_to :user, :inverse_of=>:profile
  has_and_belongs_to_many :familiarities

  validates :user, :presence => true 
  validates :contact_name, :investment_amount, :state, :city, :category, :sub_category, :seat_number, presence: true, unless: "user.entrepreneur?"
  validates :published, inclusion: { :in => [false]}, unless: "self.approved?"

  mount_uploader :business_plan, BusinessPlanUploader
  mount_uploader :company_image, CompanyImageUploader
  mount_uploader :profit_loss_statement, ProfitLossStatementUploader

  def location_state_city
    if city != nil && state != nil
      city.capitalize + ", " + state
    else
      ""
    end
  end

  def category_and_sub_category
    if category != "" && sub_category != ""
      self.category.gsub("_"," ") + " | " + self.sub_category.gsub("_"," ")
    end
  end

  def ready_to_publish?
    contains_required_fields? && approved?
  end

  #def update_status_with(status)
  #  self.update_attribute(:status, status)
  #end

  #def approve
  #  self.update_attribute(:status, "approved")
  #end

  #def publish
  #  self.update_attribute(:published, true)
  #end

  #def unpublish
  #  self.update_attribute(:published, false)
  #end

  #def deny
  #  self.update_attribute(:status, "not_approved")
  #end

  #def submit_for_approval
  #  self.update_attribute(:status, "pending_approval")
  #end

  def approved?
    self.approved == true
  end

  def approved_and_published?
    self.approved? && self.published == true
  end

  def approved_and_not_published?
    self.approved? && self.published == false
  end
  
  def not_approved?
    self.approved == false
  end

  def not_submitted?
    self.submitted == false
  end

  def submitted?
    self.submitted == true
  end

  def pending_approval?
    submitted? && not_approved?
  end

  private

  def contains_required_fields?
    ready = true
    REQUIRED_FIELDS_FOR_PUBLISHING.each do |field|
      if self.query_attribute(field) == false
        errors.add(:base, "#{field} cannot be blank")
        ready = false
      end
    end
    ready
  end

end
