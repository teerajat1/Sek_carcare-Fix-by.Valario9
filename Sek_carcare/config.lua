Config = {}

 
-----------------------------เวลา และ ท่าตอนซ่อม-------------------------------------

Config.TimeFixcar = 10 -- วิ

Config.DictFix = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@' -- DICT ของท่า

Config.AnimFix = "machinic_loop_mechandplayer" -- ANIM ของท่า

-----------------------------เวลา และ ท่าตอนล้างเคลือบ-------------------------------------

Config.TimeWashcar = 10 -- วิ

Config.DictWash = 'amb@world_human_maid_clean@idle_a' -- DICT ของท่า

Config.AnimWash = "idle_a" -- ANIM ของท่า






Config.Ped = 'a_c_chimp' -- NPC

Config.MechanicPedCoords = { -- จุดซ่อม
     {x = 170.7516, y = -1078.43, z = 29.192, h = 73.981 },
     {x = 1704.106, y = 3773.828, z = 34.536, h = 217.02 },
     {x = 45.98354, y = 6602.658, z = 32.016, h = 238.65 },
     {x = -373.366, y = -104.320, z = 38.682, h = 160.891 },

}

Config.Bliptext ='Npc-Repair'


Config.Rom = {
    Repair = {
        Case = Repair,
		text = 'ซ่อมเครื่องยนต์',
        price = 1500,
	},
    Repairout = {
        Case = Repairout,
		text = 'ซ่อมภายนอก',
        price = 1000,
	},
    Repairall = {
        Case = Repairall,
		text = 'ซ่อมทั้งหมด',
        price = 2000,
	},
    Check = {
        Case = Check,
		text = 'เช็คค่ารถ',
        price = 1,
	},
    Kloom ={
        Case = Kloom,
		text = 'เคลือบแก้ว',
        price = 200,
    },
    Wash ={
        Case = Wash,
		text = 'ล้างรถ',
        price = 500,
    },
}

Config['BlacklistName'] = { -- รถที่ซ่อมไม่ได้
    'BMX',
    'ACTROS',
    'DAF',
    'MAN',
    'T680',
    'VNL780',
    'W900',
    'actros',
    'daf',
    'man',
    't680',
    'vnl780',
    'w900',
}