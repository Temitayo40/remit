class VehiclesController < ApplicationController
  before_action :set_vehicle, only: %i[ show edit update ]

  def index
    @vehicles = Current.user.vehicles.active.by_plate
    @inactive_vehicles = Current.user.vehicles.inactive.by_plate
  end

  def show
  end

  def new
    @vehicle = Current.user.vehicles.new
  end

  def create
    @vehicle = Current.user.vehicles.new(vehicle_params)

    if @vehicle.save
      redirect_to @vehicle, notice: "#{@vehicle.plate_number} added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to @vehicle, notice: "#{@vehicle.plate_number} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_vehicle
      @vehicle = Current.user.vehicles.find(params.expect(:id))
    end

    def vehicle_params
      params.expect(vehicle: [ :plate_number, :vehicle_type, :nickname, :rate_naira, :rate_frequency, :active, rest_days: [] ])
    end
end
