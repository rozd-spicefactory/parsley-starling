/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 11:39 AM
 * To change this template use File | Settings | File Templates.
 */
package org2.spicefactory.parsley.starling.view.util
{
import starling.display.DisplayObject;
import starling.events.Event;

public class StageEventFilter
{
    /**
     * Creates a new instance that filters events for the specified view.
     *
     * @param view the view for which to filter stage events
     * @param removedHandler the handler to invoke for filtered removedFromStage events
     * @param removedHandler the handler to invoke for filtered addedToStage events
     */
    function StageEventFilter (view:DisplayObject, removedHandler:Function, addedHandler:Function = null)
    {
        this.view = view;
        this.removedHandler = removedHandler;
        this.addedHandler = addedHandler;

        view.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        view.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }

    private var view:DisplayObject;
    private var removedHandler:Function;
    private var addedHandler:Function;

    /**
     * Instructs this filter to stop listening to stage events.
     */
    public function dispose () : void
    {
        view.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
        view.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }

    private function addedToStage (event:Event) : void
    {
        if (addedHandler != null)
            addedHandler(view);
    }

    private function removedFromStage (event:Event) : void
    {
        removedHandler(view);
    }
}
}
