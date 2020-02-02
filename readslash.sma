#include < amxmodx >

#define set_bit(%1,%2)      (%1 |= (1<<(%2&31)))
#define clear_bit(%1,%2)    (%1 &= ~(1<<(%2&31)))
#define check_bit(%1,%2)    (%1 & (1<<(%2&31)))

#if AMXX_VERSION_NUM < 183
set_fail_state( "Plugin needs AMXX 1.8.3 or higher." );
#endif

new const VERSION[] = "1.7.1";

new iPriv;                  // cache priv flags
new bSlash;

public plugin_init()
{
    register_plugin( "Read Slash", VERSION, "DusT" );

    create_cvar( "Read_Slash", VERSION, FCVAR_SPONLY | FCVAR_SERVER );

    create_cvar( "amx_slash_flag", "m", .description="who can read slash messages. Change map to take effect." );

    register_clcmd( "say"           , "CheckSlash"  );
    register_clcmd( "say_team"      , "CheckSlash"  );
    register_clcmd( "say /readslash", "SlashToggle" );
}

public plugin_cfg()
{
    new szFlags[ 5 ];

    get_cvar_string( "amx_slash_flag", szFlags, charsmax( szFlags ) );

    iPriv = read_flags( szFlags );
}

public CheckSlash( id ) {

    new szArgv[ 196 ];
    read_argv( 1, szArgv, charsmax( szArgv ) );

    if( szArgv[0] == '/' ){
        new players[ 32 ], iNum; 

        get_players( players, iNum, "ch" );
        
        format( szArgv, charsmax( szArgv ), "^4[ReadSlash] %s ^3%n ^1:  %s^n", is_user_alive( id )? "":"^1*DEAD*", id, szArgv );
        
        for( new i = 0; i < iNum; i++ )
        {
            if( ( get_user_flags( players[ i ] ) & iPriv )  && !check_bit( bSlash, players[ i ] ) )
            {
                static msgSayText;
                ( msgSayText || ( msgSayText = get_user_msgid( "SayText" ) ) );
                message_begin( MSG_ONE_UNRELIABLE, msgSayText, {0,0,0}, players[ i ] );
                write_byte( id );
                write_string( szArgv );
                message_end();
            }
        }
        return PLUGIN_HANDLED_MAIN;
    } 
    return PLUGIN_CONTINUE;
}

public SlashToggle( id ){
    if( !( get_user_flags( id ) & iPriv ) )
        return PLUGIN_HANDLED;

    if( check_bit( bSlash, id ) )
    {
        clear_bit( bSlash, id );
        client_print_color( id, print_team_red, "^4[ReadSlash]^1 Slash Messages ^4ON" );
    }
    else
    {
        set_bit( bSlash, id );
        client_print_color( id, print_team_red, "^4[ReadSlash]^1 Slash Messages ^3OFF" );
    }
    return PLUGIN_HANDLED;
}

public client_disconnected( id )
    clear_bit( bSlash, id );
