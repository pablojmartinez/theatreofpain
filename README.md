Hey everyone.


This is a survival gamemode I made for a comission at the end of 2016 using Nutscript. I got permission to release it so someone can still benefit from this. I worked on it more than 150 hours, so I think it can spare a lot of time to someone who need a similar gamemode or just something exactly like this. 

These are the features:


· Basic hunger system. For restoring health you need health kits, hunger is a different bar. You can see all the bars pressing "B".


· There is a delay when you try to equip a weapon. You can modify the seconds it takes on the "Config" panel.


· Loot system. You can set positions around the map and then loot will spawn depending on the settings. You can customize the time it takes to spawn items, the chance of spawning depending on the kind of item, you can set a max amount of loot items that can spawn, etc.


· Zombie system using Vein's models and animations. The IA uses Nextbot. It's not complex but it does the job and it's perfect if you want to add more features from a simple template.


· Zombies can take down doors.


· Zombie infection system. It's simple, there is a chance to get infected. If you get infected and don't take
an injection cure then you'll eventually die. You can track the time left to die by an infection by the purple 
bar.


· Zombie spawner. Similar to the loot system, but with zombies. Use /addzombiespawn.


· Destroyable doors. You can destroy doors without locks with any weapon. Those who have locks, however, can only be destroyed with explosives. Due to the limitations of "EntityTakeDamage", explosions only works with doors if you run a hook called "OnEntityExplode" when the explosion happens. As an example I have attached a slightly modified version of the "[TFA] No More Room in Hell Unique SWEPs" so you can see how to do it. It's just a pair lines of code in the right place. You can easily modify all this in the code of the plugin, just take a look.


· Lock system. You can lock doors with padlocks. You can destroy the locks only with explosives, but you can easily change this in the code.


· Character groups. Provides a way for players to create a group of players or join one without the need of an admin. Commands are self explanatory: /creategroup, /invitetomygroup, /acceptgroupinvitations, /leavegroup, /removefromgroup. This works alongside the lock system to provide locks for the whole group and not just one 
character.


· All the items needed are already added: weapons, lots of food, an infection cure, etc. It uses external
addons. These addons may not be supported nowadays, but you could always make your own items if these doesn't do 
the job.


· Permissions for spawning weapons required, with the "w" flag.


· Each weapon stores its ammo individually, it's not shared. Once you load the ammo in one weapon then it's only
in that gun.


· All items drop when you die.


· There may be some more details, but I don't remember everything after all that time. Nutscript is also modified
to fix bugs or to make some features work, so you need both this modified Nutscript and Theatre of Pain to make it 
work properly.


As far as I remember I fixed all the known bugs, but there may be some hidden. If there is something wrong
I don't think it'd be hard to fix.


Note that there are compatibility issues with all the addons that interfere with the destruction of doors. In order to
use an addon with door destruction, like some of the shotguns of the TFA, you have to manually disable the part of the code
of the addon that is related to destroying doors.


You can use this gamemode for anything you want as long as you credit me for the development and Aizer for the design.


That's all. If you appreciate my work you can consider donating at https://www.paypal.me/PabloJMartinez, anything is appreciated.


Thanks.
