-- Default Theme for PartyChats

return {
    description = "The default theme with standard messages for abilities, spells, and weapon skills.",
    ["Savage Blade"] = {
        critical = "Savage Blade: I'm using Savage Blade!",
        fun = { "Savage Blade: Time to unleash the beast!", "Savage Blade: Let's go wild!" },
        unique = "Savage Blade: This one's for the history books!"
    },
    ["Cure IV"] = {
        critical = "Cure IV: I'm using Cure IV on TARGET!",
        fun = "Cure IV: Healing TARGET with some magic juice!"
    },
    ["Provoke"] = {
        critical = "Provoke: I'm provoking TARGET!",
        unique = { "Provoke: Hey TARGET, look at me!", "Provoke: TARGET, over here!" }
    },
    ["Raise"] = {
        critical = "Raise: Using Raise on TARGET!",
        after_mes = {
            critical = "Raise Completed on TARGET!",
            fun = "Raise: TARGET is back in action!",
            unique = "Raise: TARGET, rise and shine!"
        }
    },
    -- Add more entries as needed
}