/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 1:15 PM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.util
{
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * Filters re-parenting events for Starling's DisplayObject.
 *
 * This implementation uses <i>added</i>/<i>removed</i> events for view
 * management instead of <i>addedToStage</i>/<i>removeFromStage</i>, the reason
 * is Starling dispatches bubbling events only for first pair.
 *
 * @see org.spicefactory.parsley.core.view.util.StageEventFilter
 */
public class StarlingEventFilter
{
    /**
     * Creates a new instance that filters events for the specified view.
     *
     * @param view the view for which to filter stage events
     * @param removedHandler the handler to invoke for filtered removed events
     * @param removedHandler the handler to invoke for filtered added events
     */
    function StarlingEventFilter(view:DisplayObject, removedHandler:Function, addedHandler:Function = null)
    {
        this.view = view;
        this.removedHandler = removedHandler;
        this.addedHandler = addedHandler;

        view.addEventListener(Event.ADDED, view_addedHandler);
        view.addEventListener(Event.REMOVED, view_removedHandler);
    }

    private var view:DisplayObject;
    private var removedHandler:Function;
    private var addedHandler:Function;

    /**
     * Instructs this filter to stop listening to stage events.
     */
    public function dispose():void
    {
        view.removeEventListener(Event.ADDED, view_addedHandler);
        view.removeEventListener(Event.REMOVED, view_removedHandler);
    }

    private function view_addedHandler(event:Event):void
    {
        if (event.target != view) // ignore bubbling
            return;

        if (addedHandler != null)
            addedHandler(view);
    }

    private function view_removedHandler(event:Event):void
    {
        if (event.target != view) // ignore bubbling
            return;

        removedHandler(view);
    }
}
}
