-- potential-spork
-- v1.0.0 @icco
--
-- This script runs a clock that controls six LFOs. Each LFO is slightly offset
-- from the others. Its frequency is controlled by a connected grid. Each LFO is
-- set out a different channel to Just Friends via crow.
--
-- The clock speed is changed by turning the first encoder.
-- The clock speed is displayed on the screen.

engine.name = 'PolySub'

-- Global variables
local clock_speed = 120                            -- BPM
local lfo_frequencies = { 1, 1.2, 1.5, 2, 2.5, 3 } -- Base frequencies for each LFO
local lfo_phases = { 0, 0.1, 0.2, 0.3, 0.4, 0.5 }  -- Phase offsets for each LFO
local grid_connected = false
local grid_device = nil

function init()
  -- Initialize crow
  crow.init()

  -- Set up crow outputs for Just Friends (6 channels)
  for i = 1, 6 do
    crow.output[i].action = "voltage"
    crow.output[i].volts = 0
  end

  -- Initialize grid
  grid_device = grid.connect()
  if grid_device then
    grid_connected = true
    grid_device:all(0)
    grid_device:refresh()
  end

  -- Initialize clock
  clock.run(clock_loop)

  -- Initialize screen
  redraw()
end

function clock_loop()
  while true do
    -- Calculate LFO values for each channel
    local time = clock.time()
    for i = 1, 6 do
      local frequency = lfo_frequencies[i]
      local phase = lfo_phases[i]
      local lfo_value = math.sin(2 * math.pi * frequency * time + phase)

      -- Convert to voltage range (0-10V for Just Friends)
      local voltage = (lfo_value + 1) * 5 -- Convert from [-1,1] to [0,10]
      crow.output[i].volts = voltage
    end

    -- Wait for next clock tick
    clock.sync(1 / clock_speed)
  end
end

function key(n, z)
  -- key actions: n = number, z = state
  if n == 2 and z == 1 then
    -- Key 2 toggles clock on/off
    if clock.is_running() then
      clock.cancel()
    else
      clock.run(clock_loop)
    end
    redraw()
  end
end

function enc(n, d)
  -- encoder actions: n = number, d = delta
  -- This function changes the clock speed of the clock.
  if n == 1 then
    -- First encoder controls clock speed
    clock_speed = math.max(30, math.min(300, clock_speed + d * 5))
    redraw()
  elseif n == 2 then
    -- Second encoder controls LFO frequency scaling
    for i = 1, 6 do
      lfo_frequencies[i] = math.max(0.1, math.min(10, lfo_frequencies[i] + d * 0.1))
    end
  elseif n == 3 then
    -- Third encoder controls phase offset
    for i = 1, 6 do
      lfo_phases[i] = (lfo_phases[i] + d * 0.1) % (2 * math.pi)
    end
  end
end

function redraw()
  -- screen redraw
  -- This draws the current clock speed onto the screen.
  screen.clear()
  screen.aa(1)
  screen.font_face(1)
  screen.font_size(12)

  -- Draw title
  screen.move(10, 20)
  screen.text("potential-spork")

  -- Draw clock speed
  screen.move(10, 40)
  screen.text("clock: " .. math.floor(clock_speed) .. " bpm")

  -- Draw status
  screen.move(10, 60)
  if clock.is_running() then
    screen.text("status: running")
  else
    screen.text("status: stopped")
  end

  -- Draw grid connection status
  screen.move(10, 80)
  if grid_connected then
    screen.text("grid: connected")
  else
    screen.text("grid: disconnected")
  end

  -- Draw LFO info
  screen.move(10, 100)
  screen.text("LFOs: 6 channels to Just Friends")

  screen.update()
end

function grid.key(x, y, z)
  -- Grid key handler for controlling LFO frequencies
  if z == 1 then                                    -- Key press
    -- Map grid position to LFO frequency
    local lfo_index = math.min(6, math.ceil(x / 8)) -- 6 LFOs across grid width
    local freq_multiplier = (y / 8) * 5 + 0.1       -- Frequency multiplier based on Y position

    if lfo_index >= 1 and lfo_index <= 6 then
      lfo_frequencies[lfo_index] = freq_multiplier
    end

    -- Visual feedback
    grid_device:led(x, y, 15)
    grid_device:refresh()
  else -- Key release
    grid_device:led(x, y, 0)
    grid_device:refresh()
  end
end

function cleanup()
  -- deinitialization
  -- Stop clock
  clock.cancel()

  -- Turn off all grid LEDs
  if grid_device then
    grid_device:all(0)
    grid_device:refresh()
  end

  -- Set crow outputs to 0V
  for i = 1, 6 do
    crow.output[i].volts = 0
  end
end
