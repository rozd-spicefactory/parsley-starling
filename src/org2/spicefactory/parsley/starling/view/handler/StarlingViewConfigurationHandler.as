/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 10:18 AM
 * To change this template use File | Settings | File Templates.
 */
package org2.spicefactory.parsley.starling.view.handler
{
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.lib.util.Flag;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ViewLifecycleEvent;
import org.spicefactory.parsley.core.state.GlobalState;
import org.spicefactory.parsley.core.view.ViewAutowireMode;
import org.spicefactory.parsley.core.view.ViewConfiguration;
import org.spicefactory.parsley.core.view.ViewLifecycle;
import org.spicefactory.parsley.core.view.ViewProcessor;
import org.spicefactory.parsley.core.view.ViewRootHandler;
import org.spicefactory.parsley.core.view.ViewSettings;
import org.spicefactory.parsley.core.view.impl.DefaultViewConfiguration;
import org.spicefactory.parsley.core.view.lifecycle.AutoremoveLifecycle;
import org.spicefactory.parsley.core.view.lifecycle.CustomEventLifecycle;
import org.spicefactory.parsley.core.view.metadata.Autoremove;
import org.spicefactory.parsley.core.view.util.ViewDefinitionLookup;

import org2.spicefactory.parsley.starling.events.StarlingViewConfigurationEvent;
import org2.spicefactory.parsley.starling.view.lifecycle.StarlingAutoremoveLifecycle;
import org2.spicefactory.parsley.starling.view.util.ContextAwareEventHandler;

import starling.display.DisplayObject;
import starling.events.Event;

public class StarlingViewConfigurationHandler implements ViewRootHandler
{
    private static const log:Logger = LogContext.getLogger(StarlingViewConfigurationHandler);

    public function StarlingViewConfigurationHandler()
    {
        super();
    }

    private var context:Context;
    private var settings:ViewSettings;

    private var explicitHandler:ContextAwareEventHandler;
    private var autowireHandler:ContextAwareEventHandler;

    private var activeConfigs:Array = [];

    public function init(context:Context, settings:ViewSettings):void
    {
        this.context = context;
        this.settings = settings;
        this.explicitHandler = new ContextAwareEventHandler(context, processExplicitEvent);
        this.autowireHandler = new ContextAwareEventHandler(context, processAutowireEvent);
    }

    public function destroy():void
    {
        explicitHandler.dispose();
        autowireHandler.dispose();
        for each (var config:ViewConfiguration in activeConfigs) {
            disposeLifecycle(config);
        }
        activeConfigs = null;
    }

    public function addViewRoot(view:Object):void
    {
        view.addEventListener(StarlingViewConfigurationEvent.STARLING_CONFIGURE_VIEW, handleExplicitEvent);

        if (settings.autowireComponents)
        {
            view.addEventListener(settings.autowireFilter.eventType, prefilterView);
            view.addEventListener(StarlingViewConfigurationEvent.STARLING_AUTOWIRE_VIEW, handleAutowireEvent);
        }
    }

    public function removeViewRoot(view:Object):void
    {
        view.removeEventListener(StarlingViewConfigurationEvent.STARLING_CONFIGURE_VIEW, handleExplicitEvent);

        if (settings.autowireComponents)
        {
            view.removeEventListener(settings.autowireFilter.eventType, prefilterView);
            view.removeEventListener(StarlingViewConfigurationEvent.STARLING_AUTOWIRE_VIEW, handleAutowireEvent);
        }
    }

    private function disposeLifecycle (config:ViewConfiguration) : void {
        if (config.lifecycle) {
            config.lifecycle.stop();
            config.lifecycle.removeEventListener(ViewLifecycleEvent.DESTROY_VIEW, viewDestroyed);
            config.lifecycle.removeEventListener(ViewLifecycleEvent.INIT_VIEW, viewInitialized);
        }
    }

    //------------------------------------
    //  Methods: configuration
    //------------------------------------

    private function processConfiguration (config:ViewConfiguration) : void {
        activeConfigs.push(config);
        log.debug("Process view '{0}' with {1}", config.target, context);
        if (!config.lifecycle) {
            config.lifecycle = getLifecycle(config);
        }
        if (!config.processor) {
            config.processor = settings.viewProcessor.newInstance() as ViewProcessor;
        }
        if (!config.reuse) {
            config.reuse = new Flag(settings.reuseComponents);
        }
        config.processor.init(config, context);
        if (config.lifecycle) {
            config.lifecycle.addEventListener(ViewLifecycleEvent.DESTROY_VIEW, viewDestroyed);
            if (config.reuse && config.reuse.value) {
                config.lifecycle.addEventListener(ViewLifecycleEvent.INIT_VIEW, viewInitialized);
            }
            config.lifecycle.start(config, context);
        }
    }

    private function getLifecycle (config:ViewConfiguration) : ViewLifecycle {
        var lifecycle:ViewLifecycle = settings.newViewLifecycle(config.view);
        if (!lifecycle) {
            var autoremove:Boolean
                    = (config.autoremove)
                    ? config.autoremove.value :
                    settings.autoremoveComponents;
            if (autoremove) {
                lifecycle = new StarlingAutoremoveLifecycle();
            }
            else {
                lifecycle = new CustomEventLifecycle();
            }
        }
        return lifecycle;
    }


    //--------------------------------------------------------------------------
    //
    //  Handlers
    //
    //--------------------------------------------------------------------------

    //---------------------------------
    //  Handlers: explicit wiring
    //---------------------------------

    private function handleExplicitEvent (event:Event) : void {
        event.stopImmediatePropagation();
        if (event is StarlingViewConfigurationEvent) {
            StarlingViewConfigurationEvent(event).markAsReceived();
        }
        explicitHandler.handleEvent(event);
    }

    private function processExplicitEvent (event:Event) : void {
        var configs:Array = (event is StarlingViewConfigurationEvent)
                ? StarlingViewConfigurationEvent(event).configurations
                : [new DefaultViewConfiguration(DisplayObject(event.target))];

        for each (var config:ViewConfiguration in configs) {
            processConfiguration(config);
        }

        if (event is StarlingViewConfigurationEvent) {
            StarlingViewConfigurationEvent(event).markAsCompleted();
        }
    }

    //---------------------------------
    //  Handlers: explicit wiring
    //---------------------------------

    private function prefilterView (event:Event) : void {
        if (!AutowirePrefilterCache.addEvent(event)) return;
        var view:DisplayObject = event.target as DisplayObject;
        if (settings.autowireFilter.prefilter(view) && !GlobalState.objects.isManaged(view)) {
            view.dispatchEvent(StarlingViewConfigurationEvent.forAutowiring(view));
        }
    }

    private function handleAutowireEvent (event:Event) : void {
        event.stopImmediatePropagation();
        autowireHandler.handleEvent(event);
    }

    private function processAutowireEvent (event:StarlingViewConfigurationEvent) : void {
        for each (var config:ViewConfiguration in event.configurations) {
            var mode:ViewAutowireMode = settings.autowireFilter.filter(config.view);
            if (mode == ViewAutowireMode.NEVER) {
                return;
            }
            if (mode == ViewAutowireMode.CONFIGURED && config.definition == null) {
                config.definition = ViewDefinitionLookup.findMatchingDefinition(config, context);
                if (config.definition == null) {
                    return;
                }
                if (!config.autoremove) {
                    setAutoremoveFromMetadata(config);
                }
            }
            processConfiguration(config);
        }
    }

    private function setAutoremoveFromMetadata (config:ViewConfiguration) : void {
        var info:ClassInfo = ClassInfo.forInstance(config.view, context.domain);
        if (info.hasMetadata(Autoremove)) {
            config.autoremove = new Flag((info.getMetadata(Autoremove)[0] as Autoremove).value);
        }
    }

    //---------------------------------
    //  Handlers: lifecycle
    //---------------------------------

    private function viewDestroyed (event:ViewLifecycleEvent) : void {
        event.configuration.processor.destroy();
        if (!event.configuration.reuse || !event.configuration.reuse.value) {
            disposeLifecycle(event.configuration);
            ArrayUtil.remove(activeConfigs, event.configuration);
        }
    }

    private function viewInitialized (event:ViewLifecycleEvent) : void {
        event.configuration.processor.init(event.configuration, context);
    }
}
}
