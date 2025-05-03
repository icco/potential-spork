-- potential-spork
-- v1.0.0 @icco

m = require 'musicutil'

note = 1
scale = m.generate_scale(0, "minor", 2)

function init()
  crow.ii.jf.mode(1)
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
end

function redraw()
  screen.clear()
  screen.move(10, 40)
  screen.text("ii.jf.play_note: " .. note)
  screen.update()
end

function key(n, z)
  if n == 2 and z == 1 then
    note = note % (#scale) + 1
    crow.ii.jf.play_note(scale[note] / 12 - 1, math.random(5) + 1)
    redraw()
  elseif n == 3 and z == 1 then
    note = math.random(#scale)
    crow.ii.jf.play_note(scale[note] / 12 - 1, math.random(5) + 1)
    redraw()
  end
end

-- Function to send envelope to Just Friends via ii
-- send_jf_envelope(0.1, 0.5, 0.2, 0.3, 1) -- sends envelope to channel 1
function send_jf_envelope(attack, sustain, decay, release, channel)
  -- Set the channel (1-6)
  crow.ii.pullup(true)
  crow.ii.jf.mode(1) -- set to envelope mode
  crow.ii.jf.channel(channel)

  -- Send the envelope parameters
  crow.ii.jf.attack(attack)
  crow.ii.jf.sustain(sustain)
  crow.ii.jf.decay(decay)
  crow.ii.jf.release(release)

  -- Trigger the envelope
  crow.ii.jf.trigger()
end
