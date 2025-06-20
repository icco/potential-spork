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

function init()
  -- initialization
end

function key(n, z)
  -- key actions: n = number, z = state
end

function enc(n, d)
  -- encoder actions: n = number, d = delta
  -- This function changes the clock speed of the clock.
end

function redraw()
  -- screen redraw
  -- This draws the current clock speed onto the screen.
end

function cleanup()
  -- deinitialization
end
