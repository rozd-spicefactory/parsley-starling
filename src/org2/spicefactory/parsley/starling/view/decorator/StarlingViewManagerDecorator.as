/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/17/13
 * Time: 6:13 PM
 * To change this template use File | Settings | File Templates.
 */
package org2.spicefactory.parsley.starling.view.decorator
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

import org2.spicefactory.parsley.starling.view.handler.StarlingViewConfigurationHandler;

import starling.core.Starling;

public class StarlingViewManagerDecorator implements ViewManager, InitializingService
{
    private static const log:Logger = LogContext.getLogger(StarlingViewManagerDecorator);

    public function StarlingViewManagerDecorator(service:ViewManager, starling:Starling)
    {
        super();

        this.service = service;
        this.starling = starling;
    }

    private var service:ViewManager;

    private var starling:Starling;

    private var context:Context;
    private var settings:ViewSettings;

    private var handler:StarlingViewConfigurationHandler;

    private var activeConfigs:Array = [];

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

    private function contextDestroyed (event:ContextEvent) : void
    {
        context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);

        handler.destroy();
    }

//    private function processConfiguration (config:ViewConfiguration) : void {
//        activeConfigs.push(config);
//        log.debug("Process view '{0}' with {1}", config.target, context);
//        if (!config.lifecycle) {
//            config.lifecycle = getLifecycle(config);
//        }
//        if (!config.processor) {
//            config.processor = settings.viewProcessor.newInstance() as ViewProcessor;
//        }
//        if (!config.reuse) {
//            config.reuse = new Flag(settings.reuseComponents);
//        }
//        config.processor.init(config, context);
//        if (config.lifecycle) {
//            config.lifecycle.addEventListener(ViewLifecycleEvent.DESTROY_VIEW, viewDestroyed);
//            if (config.reuse && config.reuse.value) {
//                config.lifecycle.addEventListener(ViewLifecycleEvent.INIT_VIEW, viewInitialized);
//            }
//            config.lifecycle.start(config, context);
//        }
//    }
//
//    private function getLifecycle (config:ViewConfiguration) : ViewLifecycle {
//        var lifecycle:ViewLifecycle = settings.newViewLifecycle(config.view);
//        if (!lifecycle) {
//            var autoremove:Boolean
//                    = (config.autoremove)
//                    ? config.autoremove.value :
//                    settings.autoremoveComponents;
//            if (autoremove) {
//                lifecycle = new AutoremoveLifecycle();
//            }
//            else {
//                lifecycle = new CustomEventLifecycle();
//            }
//        }
//        return lifecycle;
//    }
//
//    private function disposeLifecycle (config:ViewConfiguration) : void {
//        if (config.lifecycle) {
//            config.lifecycle.stop();
//            config.lifecycle.removeEventListener(ViewLifecycleEvent.DESTROY_VIEW, viewDestroyed);
//            config.lifecycle.removeEventListener(ViewLifecycleEvent.INIT_VIEW, viewInitialized);
//        }
//    }
//
//    private function viewDestroyed (event:ViewLifecycleEvent) : void {
//        event.configuration.processor.destroy();
//        if (!event.configuration.reuse || !event.configuration.reuse.value) {
//            disposeLifecycle(event.configuration);
//            ArrayUtil.remove(activeConfigs, event.configuration);
//        }
//    }
//
//    private function viewInitialized (event:ViewLifecycleEvent) : void {
//        event.configuration.processor.init(event.configuration, context);
//    }
}
}
