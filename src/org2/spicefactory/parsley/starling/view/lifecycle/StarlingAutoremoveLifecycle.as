/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 11:36 AM
 * To change this template use File | Settings | File Templates.
 */
package org2.spicefactory.parsley.starling.view.lifecycle
{
import flash.events.EventDispatcher;

import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ViewLifecycleEvent;
import org.spicefactory.parsley.core.view.ViewConfiguration;
import org.spicefactory.parsley.core.view.ViewLifecycle;

import org2.spicefactory.parsley.starling.view.util.StageEventFilter;

import starling.display.DisplayObject;

public class StarlingAutoremoveLifecycle extends EventDispatcher implements ViewLifecycle
{
    private static const log:Logger = LogContext.getLogger(StarlingAutoremoveLifecycle);

    public function StarlingAutoremoveLifecycle()
    {
        super();
    }

    private var config:ViewConfiguration;
    private var context:Context;
    private var filter:StageEventFilter;
    private var active:Boolean;

    public function start(config:ViewConfiguration, context:Context):void
    {
        this.config = config;
        this.context = context;
        this.active = true;

        var addedHandler:Function = (config.reuse && config.reuse.value) ? viewAdded : null;

        this.filter = new StageEventFilter(config.view as DisplayObject, viewRemoved, addedHandler);
    }

    public function stop():void
    {
        if (filter) {
            filter.dispose();
            filter = null;
        }
        config = null;
        context = null;
    }

    private function viewRemoved (view:DisplayObject) : void
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

    private function viewAdded (view:DisplayObject) : void
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
