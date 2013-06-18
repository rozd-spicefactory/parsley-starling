/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/17/13
 * Time: 6:13 PM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.decorator
{
import flash.display.DisplayObject;

import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.lib.util.Flag;
import org.spicefactory.parsley.core.bootstrap.BootstrapInfo;
import org.spicefactory.parsley.core.bootstrap.InitializingService;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.events.ViewLifecycleEvent;
import org.spicefactory.parsley.core.view.ViewConfiguration;
import org.spicefactory.parsley.core.view.ViewLifecycle;
import org.spicefactory.parsley.core.view.ViewManager;
import org.spicefactory.parsley.core.view.ViewProcessor;
import org.spicefactory.parsley.core.view.ViewSettings;
import org.spicefactory.parsley.core.view.lifecycle.AutoremoveLifecycle;
import org.spicefactory.parsley.core.view.lifecycle.CustomEventLifecycle;

import org.spicefactory.parsley.starling.view.handler.StarlingViewConfigurationHandler;

import starling.core.Starling;

/**
 * Decorator for default ViewManager implementation. It adds support for
 * Starling projects.
 *
 */
public class StarlingViewManagerDecorator implements ViewManager, InitializingService
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    private static const log:Logger = LogContext.getLogger(StarlingViewManagerDecorator);

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function StarlingViewManagerDecorator(service:ViewManager, starling:Starling)
    {
        super();

        this.service = service;
        this.starling = starling;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var service:ViewManager;

    private var starling:Starling;

    private var context:Context;
    private var settings:ViewSettings;

    private var handler:StarlingViewConfigurationHandler;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    public function addViewRoot(view:DisplayObject):void
    {
        this.service.addViewRoot(view);
    }

    public function removeViewRoot(view:DisplayObject):void
    {
        this.service.removeViewRoot(view);
    }

    public function init(info:BootstrapInfo):void
    {
        InitializingService(this.service).init(info);

        this.context = info.context;
        this.settings = info.viewSettings;

        initStarlingViewRootHandler();

        context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
    }

    private function initStarlingViewRootHandler():void
    {
        handler = new StarlingViewConfigurationHandler();
        handler.init(context, settings);

        handler.addViewRoot(starling.stage);
    }

    private function contextDestroyed(event:ContextEvent):void
    {
        context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);

        handler.destroy();
    }
}
}
