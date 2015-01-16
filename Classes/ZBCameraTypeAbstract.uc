class ZBCameraTypeAbstract extends Object
	Abstract;




/** Actual camera instance that owns this type */
var transient ZBPlayerCamera PlayerCamera;

/** Associated camera style */
var name CameraStyle;

/** Offset this camera uses from the player */
var Vector CameraOffset;

/** Distance this camera is from the player */
var float CameraDistance;

/** Flags that we just swapped cameras and may need
 *  to do some special processing to make sure it isnt
 *  a hard cut. */
var bool CameraChange;


/************************************************************//** 
 * Constructor
 *************************************************************/

/************************************************************//** 
 * Core camera functionality
 *************************************************************/

/** CameraType specific initialization */
function Initialize();

/** Called when the camera becomes active */
function OnBecomeActive(ZBCameraTypeAbstract OldCamera);

/** Called when the camera becomes inactive */
function OnBecomeInActive(ZBCameraTypeAbstract NewCamera);

/** Core function use to calculate new camera location and rotation */
function UpdateCamera(Pawn P, ZBPlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT);

/** Sets the new view target */
simulated function BecomeViewTarget(ZombiePC PC);

/** Handles zooming in functionality */
function ZoomIn();

/** Handles zooming out functionality */
function ZoomOut();

/** Handles mobile zooming */
function MobileZoom(float Scale);

function RecordZoomStartDistance();
/** Called every tick in case there is lerping required */
simulated function Tick(float DeltaTime);

function OnSpecialMoveEnd(ZBSpecialMove SpecialMove);
DefaultProperties
{
}
