local gc=love.graphics
local int=math.floor
local function puzzleCheck(P)
	for y=1,20 do
		local L=P.field[y]
		for x=1,10 do
			local a,b=FIELD[y][x],L and L[x]or 0
			if a~=0 then
				if a==-1 then if b>0 then return end
				elseif a<12 then if a~=b then return end
				elseif a>7 then if b==0 then return end
				end
			end
		end
	end
	P.modeData.event=1
	P:win("finish")
end

return{
	color=color.white,
	env={
		Fkey=function(P)P.modeData.event=1-P.modeData.event end,
		dropPiece=puzzleCheck,
	},
	load=function()
		for k,v in next,customEnv do
			modeEnv[k]=v
		end
		if BAG[1]then
			modeEnv.bag=BAG
		else
			modeEnv.bag=nil
		end
		if MISSION[1]then
			modeEnv.mission=MISSION
		else
			modeEnv.mission=nil
		end
		PLY.newPlayer(1,340,15)
		local L=modeEnv.opponent
		if L~=0 then
			modeEnv.target=nil
			if L<6 then
				PLY.newAIPlayer(2,965,360,.5,AITemplate("9S",2*L))
			else
				PLY.newAIPlayer(2,965,360,.5,AITemplate("CC",2*L-11,int(L*.5-1.5),modeEnv.hold,4000*L))
			end
		end
		FIELD.h=20
		repeat
			for i=1,10 do
				if FIELD[FIELD.h][i]~=0 then
					goto L
				end
			end
			FIELD.h=FIELD.h-1
		until FIELD.h==0
		::L::
		modeEnv.bg=customEnv.bg
		modeEnv.bgm=customEnv.bgm
	end,
	mesDisp=function(P)
		local dx,dy=P.fieldOff.x,P.fieldOff.y
		setFont(55)
		mStr(P.stat.row,69,295)
		mText(drawableText.line,69,360)
		if P.modeData.event==0 then
			local m=puzzleMark
			for y=1,FIELD.h do for x=1,10 do
				local T=FIELD[y][x]
				if T~=0 then
					gc.draw(m[T],150+30*x-30+dx,70+600-30*y+dy)
				end
			end end
		end
	end,
}