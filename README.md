# PChats
Triggered chat tool for Windower, Written in LUA

This addon is designed to enhance the Final Fantasy XI experience by adding a bit of personality and flair to general gameplay. It can inject a dose of humor and entertainment into your party chat by automatically sending customized messages when you use certain abilities or spells. Or simply be used to call out those critical abilities or spells as they are being used.

Support for theme packs or rule packs is fully supported, being able to be tailored for a personal configuration. A Futurama theme was developed to test functionality and is a good starting point to develop more constomised packs.


Usage:

Copy all files and folders into your Windower / Addons folder.

In game activate plugin with:

//lua l pchats

In game commands:

[Activate addon - toggle]
//pchats chat

//pchats theme (filename)
Loads the theme of the filename, do not add .lua

//pchats debug_mode
Toggle - displays complete action information

//pchats fun_chance (num)
Value between 0 and 1, default is 0.3 for 30% chance

//pchats unique_chance (num)
Value between 0 and 1, default is 0.1 for 10% chance

//pchats enable_critical
Toggle - Disables mesages of this class

//pchats enable_fun
Toggle - Disables mesages of this class

//pchats enable_unique
Toggle - Disables mesages of this class
