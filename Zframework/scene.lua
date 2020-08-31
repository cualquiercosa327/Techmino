local gc=love.graphics
local abs=math.abs
local scr=scr

sceneInit,sceneBack={},{}
local sceneInit,sceneBack=sceneInit,sceneBack
sceneInit.quit=love.event.quit

local SCN={
	cur="load",--Current scene
	swapping=false,--If Swapping
	stat={
		tar=nil,	--Swapping target
		style=nil,	--Swapping style
		mid=nil,	--Loading point
		time=nil,	--Full swap time
		draw=nil,	--Swap draw  func
	},
	seq={"quit","slowFade"},--Back sequence
}--Scene datas, returned

function SCN.swapUpdate()
	local S=SCN.stat
	S.time=S.time-1
	if S.time==S.mid then
		SCN.init(S.tar,SCN.cur)
		collectgarbage()
		--Scene swapped this moment
	end
	if S.time==0 then
		SCN.swapping=false
	end
end
function SCN.init(s,org)
	if sceneInit[s]then sceneInit[s](org)end
	SCN.cur=s
	WIDGET.set(Widgets[s])
end
function SCN.push(tar,style)
	if not SCN.swapping then
		local m=#SCN.seq
		SCN.seq[m+1]=tar or SCN.cur
		SCN.seq[m+2]=style or"fade"
	end
end
function SCN.pop()
	local _=SCN.seq
	_[#_],_[#_-1]=nil
end

local swap={
	none={1,0,NULL},--swap time, change time, draw function
	flash={8,1,function()gc.clear(1,1,1)end},
	fade={30,15,function(t)
		local t=t>15 and 2-t/15 or t/15
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.W,scr.H)
	end},
	fade_togame={120,20,function(t)
		local t=t>20 and(120-t)/100 or t/20
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.W,scr.H)
	end},
	slowFade={180,90,function(t)
		local t=t>90 and 2-t/90 or t/90
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.W,scr.H)
	end},
	swipe={30,15,function(t)
		t=t/30
		gc.setColor(.1,.1,.1,1-abs(t-.5))
		t=t*t*(3-2*t)*2-1
		local w=scr.W
		gc.rectangle("fill",t*w,0,w,scr.H)
	end},
}--Scene swapping animations
function SCN.swapTo(tar,style)--Parallel scene swapping, cannot back
	local S=SCN.stat
	if not SCN.swapping and tar~=SCN.cur then
		SCN.swapping=true
		if not style then style="fade"end
		S.tar=tar
		S.style=style
		local swap=swap[style]
		S.time=swap[1]
		S.mid=swap[2]
		S.draw=swap[3]
	end
end
function SCN.go(tar,style)--Normal scene swapping, can back
	SCN.push()SCN.swapTo(tar,style)
end
function SCN.back()
	--Leave scene
	if sceneBack[SCN.cur] then sceneBack[SCN.cur]()end

	--Poll&Back to previous Scene
	local m=#SCN.seq
	if m>0 then
		SCN.swapTo(SCN.seq[m-1],SCN.seq[m])
		SCN.seq[m],SCN.seq[m-1]=nil
	end
end
return SCN