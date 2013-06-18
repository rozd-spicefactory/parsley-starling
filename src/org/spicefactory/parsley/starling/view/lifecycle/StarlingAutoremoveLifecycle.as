/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 11:36 AM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.lifecycle
{
import flash.events.EventDispatcher;

import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ViewLifecycleEvent;
import org.spicefactory.parsley.core.view.ViewConfiguration;
import org.spicefactory.parsley.core.view.ViewLifecycle;

import org.spicefactory.parsley.starling.view.util.StarlingEventFilter;

import starling.display.DisplayObject;

/**
 * Adapted AutoremoveLifecycle core class to compatible with Starling.
 *
 * @see org.spicefactory.parsley.core.view.lifecycle.AutoremoveLifecycle
 */
public class StarlingAutoremoveLifecycle extends EventDispatcher implements ViewLifecycle
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    private static const log:Logger = LogContext.getLogger(StarlingAutoremoveLifecycle);

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function StarlingAutoremoveLifecycle()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var config:ViewConfiguration;
    private var context:Context;
    private var filter:StarlingEventFilter;
    private var active:Boolean;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  Methods: ViewLifecycle
    //----------------------------------

    public function start(config:ViewConfiguration, context:Context):void
    {
        this.config = config;
        this.context = context;
        this.active = true;

        var addedHandler:Function = (config.reuse && config.reuse.value) ? viewAdded : null;

        this.filter = new StarlingEventFilter(config.view as DisplayObject, viewRemoved, addedHandler);
    }

    public function stop():void
    {
        if (filter)
        {
            filter.dispose();
            filter = null;
        }
        config = null;
        context = null;
    }

    //----------------------------------
    //  Methods: handlers
    //----------------------------------

    private function viewRemoved(view:DisplayObject):void
    {
        if (!config) return;

        if (!active)
        {
            log.info("Unexpected removedFromStage event in view '{0}'", view);
            return;
        }

        log.debug("Autoremove view '{0}' after removal from stage", view);

        active = false;

        dispatchEvent(new ViewLifecycleEvent(ViewLifecycleEvent.DESTROY_VIEW, config));
    }

    private function viewAdded(view:DisplayObject):void
    {
        if (!config) return;

        if (active)
        {
            log.info("Unexpected addedToStage event in view '{0}'", view);
            return;
        }

        log.debug("Reusable view '{0}' processed again after being added to the stage", view);

        active = true;

        dispatchEvent(new ViewLifecycleEvent(ViewLifecycleEvent.INIT_VIEW, config));
    }
}
}
