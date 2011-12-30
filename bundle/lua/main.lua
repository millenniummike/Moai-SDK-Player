MOAISim.openWindow ( "test", 640, 480 )
viewport = MOAIViewport.new ()
screenx=640
screeny=480
viewport:setSize ( screenx,screeny )
viewport:setScale ( 16, 0 )
layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
function onCollide ( event, fixtureA, fixtureB, arbiter )
if event == MOAIBox2DArbiter.BEGIN then
print ( 'begin!' )
if fixtureA.userdata and fixtureB.userdata then
print( fixtureA.userdata.." collided with " .. fixtureB.userdata)
if fixtureA.userdata=="Pellet" or fixtureB.userdata=="Pellet" then
print ("PARTICLES!")
particles(0,0)
end
end
end
if event == MOAIBox2DArbiter.END then
print ( 'end!' )
end
if event == MOAIBox2DArbiter.PRE_SOLVE then
print ( 'pre!' )
end
if event == MOAIBox2DArbiter.POST_SOLVE then
print ( 'post!' )
end
end
– set up the world and start its simulation
world = MOAIBox2DWorld.new ()
world:setGravity ( 0, 0 )
world:setUnitsToMeters ( 2 )
world:start ()
layer:setBox2DWorld ( world )
body = world:addBody ( MOAIBox2DBody.DYNAMIC )
fixture = body:addCircle( 0,0,1 )
fixture:setDensity ( 1 )
fixture:setFriction ( 0.3 )
fixture:setRestitution ( 0.5)
fixture:setFilter ( 0x01 )
fixture.userdata="Player"
fixture:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END, 0x02 )
body:resetMassData ()
body:applyAngularImpulse ( 2 )
body:setFixedRotation( true )
platform1 = world:addBody ( MOAIBox2DBody.STATIC )
fixture2 = platform1:addRect ( -5, -5, 5, -3 )
fixture2:setFilter ( 0x02 )
fixture2.userdata="Platform"
fixture2:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END, 0x00 )
platform2 = world:addBody ( MOAIBox2DBody.STATIC )
fixture2 = platform2:addRect ( 10, -5, 15, -3 )
fixture2:setFilter ( 0x02 )
fixture2.userdata="Platform"
fixture2:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END, 0x00 )
pellet1 = world:addBody ( MOAIBox2DBody.STATIC )
fixture3 = pellet1:addCircle ( 0,3,1)
fixture3:setFilter ( 0x02 )
fixture3.userdata="Pellet"
fixture3:setCollisionHandler ( onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END, 0x00 )
texture = MOAIGfxQuad2D.new ()
texture:setTexture ( 'cathead.png' )
texture:setRect ( -0.8, -0.8, 0.8, 0.8)
sprite = MOAIProp2D.new ()
sprite:setDeck ( texture )
sprite:setParent ( body )
layer:insertProp ( sprite )
camera = MOAITransform.new ()
layer:setCamera ( camera )
MOAISim.pushRenderPass ( layer )
CONST = MOAIParticleScript.packConst
local PARTICLE_X1 = MOAIParticleScript.packReg ( 1 )
local PARTICLE_Y1 = MOAIParticleScript.packReg ( 2 )
local PARTICLE_R0 = MOAIParticleScript.packReg ( 3 )
local PARTICLE_R1 = MOAIParticleScript.packReg ( 4 )
local PARTICLE_S0 = MOAIParticleScript.packReg ( 5 )
local PARTICLE_S1 = MOAIParticleScript.packReg ( 6 )
—————————————————————-
local init = MOAIParticleScript.new ()
init:randVec	( PARTICLE_X1, PARTICLE_Y1, CONST ( 2 ), CONST ( 2 ))
init:rand	 ( PARTICLE_R0, CONST ( -180 ), CONST ( 180 ))
init:rand	 ( PARTICLE_R1, CONST ( -180 ), CONST ( 180 ))
init:set	 ( PARTICLE_S0, CONST ( 1 ))
init:set	 ( PARTICLE_S1, CONST ( 1 ))
—————————————————————-
texture = MOAIGfxQuad2D.new ()
texture:setTexture ( "cathead.png" )
texture:setRect ( -0.5, -0.5, 0.5, 0.5)
system = MOAIParticleSystem.new ()
system:reserveParticles ( 256, 6 )
system:reserveSprites ( 256 )
system:reserveStates ( 1 )
system:setDeck ( texture )
system:start ()
layer:insertProp ( system )
mainThread = MOAIThread.new ()
function particles(x,y)
state1 = MOAIParticleState.new ()
state1:setTerm ( 0, 1.25 )
state1:setInitScript ( init )
state1:setPlugin ( ParticlePresets.test )
system:setState ( 1, state1 )
system:surge ( 64,x,y)
end
function move_up( )
body:applyLinearImpulse ( 0,50 )
end
function move_down( )
body:applyLinearImpulse ( 0,-50 )
end
function move_left( )
body:applyLinearImpulse (-50,0 )
end
function move_right( )
body:applyLinearImpulse ( 50,0 )
end
function move_camera ( )
bx,by= body:getPosition()
camera:setLoc ( bx, by, 3 )
end
mainThread:run (
function ()
while not gameOver do
coroutine.yield ()
move_camera( )
if MOAIInputMgr.device.mouseLeft:down () then
mX,mY= MOAIInputMgr.device.pointer:getLoc ()
if mX&gt;screenx/2+screenx/3 then
move_right ( )
end
if mXscreeny/2+screeny/3 then
move_down( )
end
end
end
end
)