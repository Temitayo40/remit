class DriversController < ApplicationController
  before_action :set_driver, only: %i[ show edit update ]

  def index
    @drivers = Current.user.drivers.active.by_name
    @inactive_drivers = Current.user.drivers.inactive.by_name
  end

  def show
  end

  def new
    @driver = Current.user.drivers.new
  end

  def create
    @driver = Current.user.drivers.new(driver_params)

    if @driver.save
      redirect_to @driver, notice: "#{@driver.name} added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @driver.update(driver_params)
      redirect_to @driver, notice: "#{@driver.name} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_driver
      @driver = Current.user.drivers.find(params.expect(:id))
    end

    def driver_params
      params.expect(driver: %i[ name phone guarantor_name guarantor_phone notes active reminders_enabled ])
    end
end
