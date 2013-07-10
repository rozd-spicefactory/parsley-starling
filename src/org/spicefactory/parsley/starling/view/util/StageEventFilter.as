/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 6/18/13
 * Time: 11:39 AM
 * To change this template use File | Settings | File Templates.
 */
package org.spicefactory.parsley.starling.view.util
{
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * Adapted StageEventFilter core class to compatible with Starling.
 *
 * @see org.spicefactory.parsley.core.view.util.StageEventFilter
 */
public class StageEventFilter
{
    private var view:DisplayObject;
    private var removedHandler:Function;
    private var addedHandler:Function;

    private var removedInCurrentFrame:Boolean;


    /**
     * Creates a new instance that filters events for the specified view.
     *
     * @param view the view for which to filter stage events
     * @param removedHandler the handler to invoke for filtered removedFromStage events
     * @param removedHandler the handler to invoke for filtered addedToStage events
     */
    function StageEventFilter (view:DisplayObject, removedHandler:Function, addedHandler:Function = null) {
        this.view = view;
        this.removedHandler = removedHandler;
        this.addedHandler = addedHandler;
        view.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        view.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }


    /**
     * Instructs this filter to stop listening to stage events.
     */
    public function dispose () : void {
        view.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
        view.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        view.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private function addedToStage (event:Event) : void {
        if (removedInCurrentFrame) {
            resetFrame();
        }
        else if (addedHandler != null) {
            addedHandler(view);
        }
    }

    private function removedFromStage (event:Event) : void {
        removedInCurrentFrame = true;
        view.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private function enterFrame (event:Event) : void {
        resetFrame();
        removedHandler(view);
    }

    private function resetFrame () : void {
        removedInCurrentFrame = false;
        view.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }
}
}
