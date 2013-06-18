/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 11:21 AM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.util
{
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;

import starling.events.Event;

/**
 * Adapted ContextAwareEventHandler utility class to compatible with Starling.
 *
 * @see org.spicefactory.parsley.core.view.util.ContextAwareEventHandler
 */
public class ContextAwareEventHandler
{
    /**
     * Creates a new instance.
     *
     * @param context the associated Context
     * @param handler the handler to invoke for each event
     */
    function ContextAwareEventHandler(context:Context, handler:Function)
    {
        this.context = context;
        this.handler = handler;
    }

    private var context:Context;
    private var handler:Function;

    private var cachedEvents:Array = new Array();

    /**
     * Handles the specified event, potentially deferring the target handler invocation in case the
     * associated Context is not fully initialized yet.
     *
     * @param event the event to handle
     */
    public function handleEvent(event:Event):void
    {
        if (context.initialized)
        {
            handler(event);
        }
        else
        {
            if (cachedEvents.length == 0)
            {
                context.addEventListener(ContextEvent.INITIALIZED, handleCachedEvents);
            }
            cachedEvents.push(event);
        }
    }

    private function handleCachedEvents(contextEvent:ContextEvent):void
    {
        context.removeEventListener(ContextEvent.INITIALIZED, handleCachedEvents);
        for each (var event:Event in cachedEvents)
        {
            handler(event);
        }
        cachedEvents = new Array();
    }

    /**
     * Dispose this event handler, clearing its internal cache of events that needed deferral.
     */
    public function dispose():void
    {
        if (cachedEvents.length > 0)
        {
            context.removeEventListener(ContextEvent.INITIALIZED, handleCachedEvents);
            cachedEvents = new Array();
        }
    }

}
}
