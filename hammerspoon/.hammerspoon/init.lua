hs.ipc.cliInstall()

local preferredInputs = {
  "DJI MIC MINI",
  "Yeti Stereo Microphone",
}

local retryDelays = { 0.25, 1, 2.5 }

local function findPreferredInput()
  for _, preferredName in ipairs(preferredInputs) do
    local device = hs.audiodevice.findInputByName(preferredName)
    if device then
      return device
    end
  end

  return nil
end

local function setPreferredInputIfAvailable()
  local preferred = findPreferredInput()
  if not preferred then
    return
  end

  local current = hs.audiodevice.defaultInputDevice()
  if not current or current:name() ~= preferred:name() then
    preferred:setDefaultInputDevice()
    hs.alert.show("Audio input: " .. preferred:name())
  end
end

hs.audiodevice.watcher.setCallback(function(event)
  for _, delay in ipairs(retryDelays) do
    hs.timer.doAfter(delay, setPreferredInputIfAvailable)
  end
end)

hs.audiodevice.watcher.start()
setPreferredInputIfAvailable()
