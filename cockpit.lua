local scriptSettings = ac.INIConfig.scriptSettings()
local cfg = scriptSettings:mapSection('SETTINGS', {
  FILTER_LEVEL = 0.8,
  BLEND_LOW_SPEED = 1.0,
  BLEND_HIGH_SPEED = 4.0,
  SLIDE_FOLLOWING = 0,
  MAX_ANGLE_DEG = 15.0,
  REPLAY_FILTER_LEVEL = 0.1,
  FIRST_LAUNCH = true
})

local innerCfg = ac.storage({ firstLaunch = true })
if innerCfg.firstLaunch then
  innerCfg.firstLaunch = false
  local neckCfg = ac.INIConfig.load(ac.getFolder(ac.FolderID.ExtCfgUser) .. '/neck.ini')
  if (neckCfg.sections.LOOKAHEAD or neckCfg.sections.ALIGNMENT_BASE or neckCfg.sections.ALIGNMENT_VR)
      and not next(scriptSettings.sections)
      and not neckCfg.sections.SCRIPT then
    neckCfg:setAndSave('SCRIPT', 'ENABLED', false)
  end
end

local function isSlideFollowingEnabled()
  local v = cfg.SLIDE_FOLLOWING
  if v == nil then return false end
  if type(v) == "boolean" then return v end
  local n = tonumber(v)
  if n ~= nil then return n ~= 0 end
  return false
end

local function lowSpeedBlend(speed)
  if speed < cfg.BLEND_LOW_SPEED then
    return 0.0
  elseif speed < cfg.BLEND_HIGH_SPEED then
    return (speed - cfg.BLEND_LOW_SPEED) / (cfg.BLEND_HIGH_SPEED - cfg.BLEND_LOW_SPEED)
  else
    return 1.0
  end
end

local smoothedLook            = vec3(0, 0, 1)
local smoothedUp              = vec3(0, 1, 0)
local smoothedYaw             = 0.0

local replayVelocity          = vec3(0, 0, 0)

local maxAngle                = math.rad(cfg.MAX_ANGLE_DEG)
local angleLocked             = false
local softLockDulationEnabled = false
local softLockMaxDuration     = 0.5
local softLockDulationCounter = 0.0

local function updateNeckOrientation(dt)
  -- 目標方向を取得・直交化（look と up を正規直交基底にする）
  -- 速度ベクトルを向く
  local velocity = nil
  if ac.isInReplayMode() then
    replayVelocity = math.applyLag(replayVelocity, car.velocity:clone(), cfg.REPLAY_FILTER_LEVEL, dt)
    velocity = replayVelocity:clone()
  else
    velocity = car.velocity:clone()
  end
  velocity:sub(car.up:clone():scale(car.up:clone():dot(car.velocity:clone())))

  local dot = velocity:clone():dot(car.look:clone())
  if dot < 0 then
    velocity:scale(-1)
  end
  local velocityProj = nil
  if velocity:length() > 1e-6 then
    velocityProj = velocity:clone():normalize()
  end

  local blend = lowSpeedBlend(velocity:clone():length())
  local targetLook = nil
  if velocityProj then
    if isSlideFollowingEnabled() then
      targetLook = velocityProj:clone():scale(blend):add(car.look:clone():scale(1.0 - blend))
    else
      targetLook = car.look:clone()
    end
  else
    targetLook = car.look:clone()
  end
  targetLook:normalize()

  --local angle = targetLook:clone():angle(car.look:clone()) -- バグ
  local a = targetLook:clone():normalize()
  local b = car.look:clone():normalize()
  local dot_ab = math.clamp(a:dot(b), -1, 1)
  local angle = math.acos(dot_ab)
  local axis = car.look:clone():cross(targetLook:clone())
  if angle > maxAngle then
    if angleLocked == false then
      angleLocked = true
    end
    if axis:length() < 1e-6 then
      axis = car.up:clone() -- degenerate の場合は up を使う（安全策）
    end
    axis:normalize()
    smoothedYaw = math.applyLag(smoothedYaw, math.sign(axis:clone():dot(car.up:clone())) * maxAngle, cfg.FILTER_LEVEL, dt)
    targetLook = car.look:clone():rotate(quat.fromAngleAxis(smoothedYaw, car.up:clone())):normalize()
  else
    smoothedYaw = math.applyLag(smoothedYaw, math.sign(axis:clone():dot(car.up:clone())) * angle, cfg.FILTER_LEVEL, dt)
    if angleLocked then
      angleLocked = false
      if dot < 0 then
        softLockDulationEnabled = true
      end
    end
    if softLockDulationEnabled then
      targetLook = car.look:clone():rotate(quat.fromAngleAxis(smoothedYaw, car.up:clone())):normalize()
      softLockDulationCounter = softLockDulationCounter + dt
      if softLockDulationCounter >= softLockMaxDuration then
        softLockDulationEnabled = false
        softLockDulationCounter = 0.0
      end
    end
  end

  local targetUp   = car.up:clone():normalize()

  local targetSide = targetLook:clone():cross(targetUp)
  if targetSide:length() < 1e-6 then
    -- degenerate の場合は world up を使う（安全策）
    targetUp = vec3(0, 1, 0)
    targetSide = targetLook:clone():cross(targetUp)
  end
  targetSide:normalize()
  targetUp     = targetSide:clone():cross(targetLook):normalize()

  -- EMA / 一階遅延で平滑化（math.applyLag を利用）
  smoothedLook = math.applyLag(smoothedLook, targetLook, cfg.FILTER_LEVEL, dt)
  smoothedUp   = math.applyLag(smoothedUp, targetUp, cfg.FILTER_LEVEL, dt)

  smoothedLook:sub(targetSide:scale(targetSide:dot(smoothedLook))):normalize() -- look から side 成分を除去

  -- 正規直交化して neck に反映
  neck.look:set(smoothedLook):normalize()
  local s = vec3():setCrossNormalized(neck.look, smoothedUp) -- side = look x up (normalized)
  neck.side:set(s)
  neck.up:setCrossNormalized(neck.side, neck.look)           -- up = side x look (normalized)
end

local beforePos = nil
local function updateHeave(dt)
  if beforePos == nil then
    beforePos = car.position:clone()
  end

  local movement = car.position:clone():sub(beforePos)
  local neck_up = movement:dot(car.up:clone())

  beforePos = car.position:clone()

  local smoothedHeave = math.applyLag(neck.position:clone(), neck.position:clone():addScaled(car.up:clone(), neck_up),
    cfg.FILTER_LEVEL, dt)
  neck.position:set(smoothedHeave)
end


function script.update(dt, mode, turnMix)
  updateNeckOrientation(dt)
  updateHeave(dt)
end
