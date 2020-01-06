#include < amxmodx >

#define set_bit(%1,%2)      (%1 |= (1<<(%2&31)))
#define clear_bit(%1,%2)    (%1 &= ~(1<<(%2&31)))
#define check_bit(%1,%2)    (%1 & (1<<(%2&31)))

#if AMXX_VERSION_NUM < 183
set_fail_state( "Plugin needs AMXX 1.8.3 or higher." );
#endif

new pCvarFlag;
new iPriv;                  // cache priv flags
new bSlash;

public plugin_init()
{
    register_plugin( "Read Slash", "1.6", "DusT" );

    register_cvar( "AmX_DusT", "Read_Slash", FCVAR_SPONLY | FCVAR_SERVER );

    pCvarFlag = register_cvar( "amx_slash_flag", "m" );

    register_clcmd( "say"           , "CheckSlash"  );
    register_clcmd( "say_team"      , "CheckSlash"  );
    register_clcmd( "say /readslash", "SlashToggle" );
}

public plugin_cfg()
{
    new szFlags[ 5 ];

    get_pcvar_string( pCvarFlag, szFlags, charsmax( szFlags ) );

    iPriv = read_flags( szFlags );
}

public CheckSlash( id ) {

    new szArgv[ 196 ];
    read_argv( 1, szArgv, charsmax( szArgv ) );

    if( szArgv[0] == '/' ){
        new players[ 32 ], iNum; 

        get_players( players, iNum, "c" );
        
        format( szArgv, charsmax( szArgv ), "^x04[ReadSlash] %n ^x03%s ^x01:  %s^n", is_user_alive( id )? "":"^x01*DEAD*", id, szArgv );
        
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
        client_print( id, print_chat, "[ReadSlash] Slash Messages ON" );
    }
    else
    {
        set_bit( bSlash, id );
        client_print( id, print_chat, "[ReadSlash] Slash Messages OFF" );
    }
    return PLUGIN_HANDLED;
}

public client_disconnected( id )
    clear_bit( bSlash, id );
