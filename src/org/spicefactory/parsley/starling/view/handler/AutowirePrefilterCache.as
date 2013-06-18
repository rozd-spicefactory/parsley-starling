/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 11:23 AM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.handler
{
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import starling.events.Event;

/**
 *
 * Adapted AutowirePrefilterCache core class for using with Starling.
 *
 * @see org.spicefactory.parsley.core.view.handler.AutowirePrefilterCache
 */
public class AutowirePrefilterCache
{

    private static var cachedEvents:Dictionary = new Dictionary();
    private static var purgeTimer:Boolean;

    /**
     * Adds the specified Event to the cache.
     *
     * @param event the event to add
     * @return true if the event has been added to the cached, false if it has already been prefiltered
     */
    public static function addEvent(event:Event):Boolean
    {
        if (cachedEvents[event]) return false;

        cachedEvents[event] = true;

        if (!purgeTimer)
        {
            purgeTimer = true;
            setTimeout(purgePrefilterCache, 1);
        }

        return true;
    }

    private static function purgePrefilterCache():void
    {
        purgeTimer = false;
        cachedEvents = new Dictionary();
    }

}
}