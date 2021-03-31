
unit meshmain;

{$mode objfpc}{$H+}
{$define DONT_LINK_EXTRAS}

// http://wiki.freepascal.org/OpenGL_Tutorial
// http://www.cprogramming.com/graphics-programming.html
// http://geomalgorithms.com/a06-_intefwaterlinersect-2.html
{
To do:-
snap to centreline
cutting at frames
snap frames ready for cuts
sideview


}
interface

uses
  Classes, SysUtils, FileUtil, OpenGLContext, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Buttons, StdCtrls, ExtCtrls, Menus, gl,
  glu, types, infounit, TwoDtothreeD, portholesunit;

const
 maxundo= 10;
//  view:integer=1;
  topview=1;
  frontview=2;
  sideview=3;
  mainview=4;

  dotlinethickness=1;
  slicelinewidth=3;
  framelinewidth=9;
  frontframelinewidth=5;
  frontframelinewidthinner=3;

  framelinewidthinner=5;
  circlelinewidth=2;
  slices: integer = 0;
  frames: integer = 0;
  maxframes = 20;
  maxslices = 20;
  normalface = 0;
  normalfacestr = '0';
  anyface = -1;
  frameface = 1;
  skinface = 2;
  skinfacestr = '2';
  edgeface = 3;
  topwallthickness = 1;
  bluntgap :integer= 4;
  sharpgap:integer = -1;
  floorgap:integer = 1;
  cutthickness :integer= 2;
//  framethickness = wallthickness;
  splinedots: integer = 8;
  tinydots=100;
  outside=1;
  inside=2;
  usecache:boolean=True;

//  background:array[0..3] of GLclampf =($aa,$aa,$aa,$aa);
  background:array[0..3] of GLclampf =($a8/256,$a8/256,$bf/256,$ff/256);

  screencolor = $aaaaaa;
  gridcolor = clmaroon;
  gridzerocolor=clblue;
  plancolor=clwhite;
  finegridcolor= clltgray;
  unselectedlinecolor = clblack;
  selectedlinecolor = clblue;
  frameinnercolor=clltgray;
  selectedlinewidth=3;
  unselectedlinewidth=1;
  circlehighlightcolor= clpurple;
  circlelolightcolor= clblue;
  screenlightcolor=claqua;
  framecutstart:integer=0;
  framecutend:integer=0;
//  mousemoved: boolean = True;
  restrictcache:boolean=false;



type

 // Tmylist=Tlist;
  pdouble=^double;


  // Tquaternion=array[1..4] of double;
   Tquaternion=record
                    case isround:integer of
                      1:
                        (a:double;
                    b:double;
                    c:double;
                    d:double;
                        );
                      2:
                          (unused:double;
                      i:double;
                      j:double;
                      k:double;
                          );

                    3:
                      (v:array[1..4] of double);
                end;

   single = double;

  xyzArray = array[1..10, 0..100, 1..10] of longint;

  TColor3f = record
    R, G, B: single;
  end;

  Tdrawitem = record
    seq: integer;
    token: integer;
    nx, ny, nz: double;
    cr, cg, cb: double;
    x1, y1, z1: double;
    x2, y2, z2: double;
    x3, y3, z3: double;
    n1, n2, n3: integer;  //neighbour to face 1,2,3

    free1, free2, free3: integer;
    facingedges: integer;
    elementnumber: integer; //identifies face
    ItemIndex: integer;  //item within element
    parent: integer;
    wall: integer;
    tagged: integer;
    nodename:string[40];
  end;


  Tmypoint = record
    x: double;
    y: double;
    z: double;

  end;

  Tmypointarray = array[0..3] of TMypoint;

  Tnode = record
    x: double;
    y: double;
    z: double;
    verticalcrease: boolean;
    horizontalcrease: boolean;
    foreaftcrease:boolean;
    cutframe: boolean;
    straightframe: boolean;
    bulkhead: boolean;
    setx0: boolean;
    sety0: boolean;
    setz0: boolean;
    roundbottom: boolean;
    sealevel:boolean;
//    linked:boolean;
    group:integer;
  end;

  Tcontrolnodes= record
   node:array[1..maxframes, 1..maxslices] of Tnode;
  end;

  { TMeshmainform }

  TMeshmainform = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    CacheoffBitBtn: TBitBtn;
    CacheOnBitBtn: TBitBtn;
    ColorDialog1: TColorDialog;
    IsoBitBtn: TBitBtn;
    LoadAnyMenuItem: TMenuItem;
    CreateKeelMenuItem: TMenuItem;
    ColorMenuItem: TMenuItem;
    MenuItem2: TMenuItem;
    Saveenvironment: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveanyMenuItem: TMenuItem;
    SaveDialog1: TSaveDialog;
    TailIsoBitBtn: TBitBtn;
    MenuItem1: TMenuItem;
    CreateStlMenuItem: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    DrawplankMenuItem: TMenuItem;
    createinsideMenuItem: TMenuItem;
    ShowInandOutMenuItem: TMenuItem;
    MenuItemPortholes: TMenuItem;
    ShowOutsideMenuItem: TMenuItem;
    ShowInsideMenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    BothSidesMenuItem: TMenuItem;
    MenuItem4: TMenuItem;
    ToolBar2: TToolBar;
    TopViewMenuItem: TMenuItem;
    SideViewMenuItem: TMenuItem;
    FrontViewMenuItem: TMenuItem;
    SetScaleMenuItem: TMenuItem;
    Rockmenuitem: TMenuItem;
    SealevelButton: TButton;
    MainMenu1: TMainMenu;
    FileMenuItem: TMenuItem;
    LoadMenuItem: TMenuItem;
    ExportSTLMenuItem: TMenuItem;
    InformationMenuItem: TMenuItem;
    AboveMenuItem: TMenuItem;
    ClearSTLMenuItem: TMenuItem;
    SetwireframeMenuItem: TMenuItem;
    DrawfullMenuItem: TMenuItem;
    HidedrawingMenuItem: TMenuItem;
    ExportpartialMenuItem: TMenuItem;
    RX1TrackBar: TTrackBar;
    rxtrackbar: TTrackBar;
    WireframeMenuItem: TMenuItem;
    SaveMenuItem: TMenuItem;
    ShowdatabaseButton: TButton;
    Memo1: TMemo;
    OpenGLControl1: TOpenGLControl;
    RZTrackBar: TTrackBar;
    RangeTrackBar: TTrackBar;
    RYTrackBar: TTrackBar;
    procedure CacheoffBitBtnClick(Sender: TObject);
//    procedure ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
    procedure BothSidesMenuItemClick(Sender: TObject);
    procedure CacheOnBitBtnClick(Sender: TObject);
    procedure ColorMenuItemClick(Sender: TObject);
    procedure CreateKeelMenuItemClick(Sender: TObject);
    procedure CreateStlMenuItemClick(Sender: TObject);
    procedure DrawplankMenuItemClick(Sender: TObject);
    procedure ExportpartialMenuItemClick(Sender: TObject);
    procedure ExportSTLMenuItemClick(Sender: TObject);
    procedure FaceMenuItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FrontViewMenuItemClick(Sender: TObject);
    procedure IsoBitBtnClick(Sender: TObject);
    procedure LoadAnyMenuItemClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure RX1TrackBarChange(Sender: TObject);
    procedure rxtrackbarChange(Sender: TObject);
    procedure SaveanyMenuItemClick(Sender: TObject);
    procedure SaveenvironmentClick(Sender: TObject);

    procedure TailIsoBitBtnClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure Face3dWork(Sender: TObject);
    procedure MenuItem2to3dClick(Sender: TObject);
    procedure MenuItemPortholesClick(Sender: TObject);
    procedure ShowInandOutMenuItemClick(Sender: TObject);
    procedure ShowInsideMenuItem1Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure RockmenuitemClick(Sender: TObject);
    procedure SealevelButtonClick(Sender: TObject);
    procedure InformationMenuItemClick(Sender: TObject);
    procedure LoadMenuItemClick(Sender: TObject);
    procedure ClearSTLMenuItemClick(Sender: TObject);
    procedure Createinside;

    procedure SetScaleMenuItemClick(Sender: TObject);
    procedure SetwireframeMenuItemClick(Sender: TObject);
    procedure DrawfullMenuItemClick(Sender: TObject);
    procedure HidedrawingMenuItemClick(Sender: TObject);
    procedure OpenGLControl1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure SaveMenuItemClick(Sender: TObject);
    procedure ShowdatabaseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure OpenGLControl1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
    procedure OpenGLControl1Paint(Sender: TObject);
    procedure OpenGLControl1Resize(Sender: TObject);
    procedure updatetrackbar(Sender: TObject);
    procedure RyTrackBarChange(Sender: TObject);
    procedure RzTrackBarChange(Sender: TObject);

    procedure RangeTrackBarChange(Sender: TObject);
    procedure ShowOutsideMenuItemClick(Sender: TObject);
    procedure SideViewMenuItemClick(Sender: TObject);
    procedure createinsideMenuItemClick(Sender: TObject);
    procedure TopViewMenuItemClick(Sender: TObject);
    procedure getcentre(var x,y,z:double);
    procedure STLexport;
  private
  public

    cube_rotationx: GLFloat;
    cube_rotationy: GLFloat;
    cube_rotationz: GLFloat;
    Function validnode:boolean;

    procedure cleargoodlist;
    procedure handlemymessage;
    procedure refreshall;
    procedure refreshall(firstview:integer);

    Procedure drawmesh;
    Procedure drawplanked;
    //draws from list to save recalculation
    procedure fastdrawSTL;

    Procedure drawfilledmesh;
    procedure trackbarupdate;
   Procedure gl_setcolor(mycolor:Tcolor);
   procedure createstl(startframe,endframe,
     {0 for no cut ,1 for cover cut, 2 make full face} sealstart,sealend:integer);


  end;


var
  framethickness :double=10;
  rangeslider:integer=0;
  startrotationx:Integer=0;
  startrotationy:Integer=0;
  list_object:Integer=1;

  currentframe:Integer = 0;
  currentslice:integer=0;

  pstoreditem:pdouble;
  goodlist:Tlist;

  qaxisrotation,qfinal:Tquaternion;
  savednode:Tnode;
  showinside:boolean = false;
  showoutside:boolean = true;

  Meshmainform: TMeshmainform;
  rock:boolean=false;
  rockangle:double=0;
  wallthickness:double = 10;

  ItemIndex: integer = 0;
  nurbindex: integer = 0;
  edgeindex: integer = 0;
  elementindex: integer = 0;
  startmovex: double = 0;
  startmovey: double = 0;
  startmoveoffsetx: double = 0;
  startmoveoffsety: double = 0;
  offsetx: double = 0;
  offsety: double = 0;
  scale: double = 1;
  xyzscale:double=1;
  face:boolean = false;
  leftmouseisdown: boolean = False;
//  showinside:boolean = false;
//  showoutside:boolean = true;
    currentside:integer=1;

  fixednode:boolean = false;
//  controlnodes: array[1..maxframes, 1..maxslices] of Tnode;
//  skincontrolnodes: array[1..maxframes, 1..maxslices] of Tnode;
//  outsidecontrolnodes:Tcontrolnodes;
//  insidecontrolnodes:Tcontrolnodes;

  controlnodes:array[1..2] of Tcontrolnodes;


  ControlPoints: xyzArray;
  lastselectedframe: integer = 1;
  lastselectedslice: integer = 1;

  selectedframe: integer = 1;
  selectedslice: integer = 1;
  //lockselection:boolean=false;

  frametomove: integer = 0;
  slicetomove: integer = 0;

//  mousemoved: boolean = True;
  wireframe: boolean = False;
  filledmesh:boolean = true;
  plank:boolean=false;
  hullonly: boolean = True;
  showframes:boolean=true;
  bothsides:boolean=false;
//  trianglelist:Tstringlist;
  hidedrawing: boolean = false;
  sealevel:Double=0;
//  currentnodes:Tcontrolnodes;  // may be inside or outside
  currentnode:Tnode;
  highlight: boolean;
  currentfilename:string='';

implementation

{$R *.lfm}
uses meshutilsunit, databaseunit,  gltopviewunit, imagingopengl,partialexportunit,
  glsideviewunit,glfrontviewunit, splineunit,selectcutmenuunit,setscaleunit,face3dunit;

const
  DiffuseLight: array[0..3] of GLfloat = (0.9, 0.9, 0.9, 0.9);

var
  lastrx,lastry,lastrz:double;


  /////////////////////////////////////////////////////
  Procedure TmeshmainForm.gl_setcolor(mycolor:Tcolor);
  /////////////////////////////////////////////////////
  var
    temp:longint;
  //  r,g,b:double;
    r,g,b:integer;
  begin
     temp := mycolor;
  {   r := (temp mod 256)/256;
     temp := temp div 256;
     g := (temp mod 256)/256;
     temp := temp div 256;
     b := (temp mod 256)/256;}

     r := (temp mod 256);
      temp := temp div 256;
      g := (temp mod 256);
      temp := temp div 256;
      b := (temp mod 256);


     glcolor3f(r,g,b);
   //    glcolor4ub(r,g,b,$80);

  end;



//////////////////////////////////////////
Function Tmeshmainform.validnode:boolean;
//////////////////////////////////////////
begin
  if (selectedframe > 0) and (selectedslice>0) then
    result := true
  else

  result := false;
end;


////////////////////////
procedure Tmeshmainform.trackbarupdate;
////////////////////////
var
 qx,qz,qy1:tquaternion;
 xvec,yvec,zvec:Tquaternion;
 deltarx,deltary,deltarz:double;
begin
  deltarx := (-lastrx + rxtrackbar.position);
  deltary := (-lastry + rytrackbar.position);
  deltarz := (-lastrz + rztrackbar.position);



  xvec := meshutilsform.qsetup(0,1,0,0);
  yvec := meshutilsform.qsetup(0,0,1,0);
  zvec := meshutilsform.qsetup(0,0,0,1);

  // qfinal := meshutilsform.tracktoquaternion(0,0,1,0);;
  xvec := meshutilsform.qvectorbyq(meshutilsform.qconjugate(qfinal),{vector}xvec);
//  qx := meshutilsform.tracktoquaternion(rxtrackbar.Position,xvec.b,xvec.c,xvec.d);
//  qfinal:=meshutilsform.qmultiply(qfinal,qx);

  qx := meshutilsform.tracktoquaternion(deltarx,xvec.b,xvec.c,xvec.d);
  qfinal:=meshutilsform.qmultiply(qfinal,qx);


  yvec := meshutilsform.qvectorbyq(meshutilsform.qconjugate(qfinal),{vector}yvec);
  qy1 := meshutilsform.tracktoquaternion(deltary,yvec.b,yvec.c,yvec.d);
  qfinal:=meshutilsform.qmultiply(qfinal,qy1);

  zvec := meshutilsform.qvectorbyq(meshutilsform.qconjugate(qfinal),{vector}zvec);
//
  qz := meshutilsform.tracktoquaternion(deltarz,zvec.b,zvec.c,zvec.d);
  qfinal:=meshutilsform.qmultiply(qfinal,qz);


  meshutilsform.testq(qfinal);

//  qy1 := meshutilsform.tracktoquaternion(rx1trackbar.Position,xvec.b,xvec.c,xvec.d);
//  qfinal:=meshutilsform.qmultiply(qfinal,qy1);



  qaxisrotation := meshutilsform.qtoaxis(qfinal);
  openglcontrol1.Paint;
  lastrx := rxtrackbar.position;
  lastry := rytrackbar.position;
  lastrz := rztrackbar.position;



end;



////////////////////////////////////////////////////
procedure Tmeshmainform.getcentre(var x,y,z:double);
////////////////////////////////////////////////////
var

  min,max:double;
begin
  if frames = 0 then exit;
  min := controlnodes[1].node[1,1].x ;
  max := controlnodes[1].node[frames,slices].x;
  x := (max-min)/2;
//  x := 0;
  min := controlnodes[1].node[frames div 2,1].y ;
  max := controlnodes[1].node[frames div 2,slices].y ;
  y := (max-min)/2;
  y := 0;
  min := controlnodes[1].node[frames div 2,1].z ;
  max := controlnodes[1].node[frames div 2,slices].z ;
  z := (max-min)/2;
//  x:=0;
//  y:=0;
//  z:=0;
end;


/////////////////////////////////
Procedure Tmeshmainform.drawplanked;
/////////////////////////////////

procedure drawnodes(side:integer;mynode:Tcontrolnodes);
var
  i,j:Integer;
  x,y,z:double;
  x1,y1,z1:double;
  dx,dy,dz:double;
//  framenow,slicenow:Integer;
begin
  dx:=0;
  dy:=0;
  dz:=0;
  getcentre(dx,dy,dz);
  for j := 0 to splineform.getverticalpoints-1 do
    begin
      for i := 0 to splineform.gethorizontalpoints-1 do
        begin
          splineform.indexedintermediatepoint(mynode,side,i,j,x,y,z);
          splineform.indexedintermediatepoint(mynode,side,i+1,j,x1,y1,z1);
//          framenow := (i div splinedots) +1;
          y := -y;
          y1 := -y1;
          x := x - dx;
          y := y -dy;
          z := z -dz;
          x1 := x1 - dx;
          y1 := y1 -dy;
          z1 := z1 -dz;
          glBegin(GL_lines);
          glvertex3f(x,y,z);
          glvertex3f(x1,y1,z1);
          glend();
          if bothsides then
            begin
              glBegin(GL_lines);
              glvertex3f(x,-y,z);
              glvertex3f(x1,-y1,z1);
              glend();
            end;
        end;
    end;
  for i := 0 to frames-1  do
    begin
      for j := 0 to splineform.getverticalpoints -1  do
        begin
          splineform.indexedintermediatepoint(mynode,side,i*splinedots,j,x,y,z);
          splineform.indexedintermediatepoint(mynode,side,i*splinedots,j+1,x1,y1,z1);
          y := -y;
          y1 := -y1;
          x := x - dx;
          y := y -dy;
          z := z -dz;
          x1 := x1 - dx;
          y1 := y1 -dy;
          z1 := z1 -dz;
          glBegin(GL_lines);
          if (i = pred(selectedframe)) then
            begin
              //glLineWidth(3.0);
              glcolor4f(1.0,1.0,1.0,1.0) ;
            end
          else
            begin
             // glLineWidth(1.0);
              glcolor4f(0.9,0.3,0.9,1.0);
            end;
          glvertex3f(x,y,z);
          glvertex3f(x1,y1,z1);
          glend();
          if bothsides then
            begin
              glBegin(GL_lines);
              glvertex3f(x,-y,z);
              glvertex3f(x1,-y1,z1);
              glend();
            end;
        end;
    end;
end;

begin
  glLineWidth(1.0);

  if showoutside then
    drawnodes(outside,controlnodes[outside]);
  if showinside then
    drawnodes(inside,controlnodes[inside]);


end;


/////////////////////////////////
Procedure Tmeshmainform.drawmesh;
/////////////////////////////////
//wire mesh
procedure drawnodes(side:integer;mynode:Tcontrolnodes);
///////////////////////////////////////////////////////
var
  i,j:Integer;
  x,y,z:double;
  x1,y1,z1:double;
  dx,dy,dz:double;
//  framenow,slicenow:Integer;
begin
  dx:=0;
  dy:=0;
  dz:=0;
  getcentre(dx,dy,dz);
  for j := 0 to slices -1 do
    begin
      if j = selectedslice -1 then
        gl_setcolor(selectedlinecolor)
      else
        gl_setcolor(unselectedlinecolor);



      for i := 0 to splineform.gethorizontalpoints-1 do
        begin
          splineform.indexedintermediatepoint(mynode,side,i,j*splinedots,x,y,z);
          splineform.indexedintermediatepoint(mynode,side,i+1,j*splinedots,x1,y1,z1);
//          framenow := (i div splinedots) +1;
          y := -y;
          y1 := -y1;
          x := x - dx;
          y := y -dy;
          z := z -dz;
          x1 := x1 - dx;
          y1 := y1 -dy;
          z1 := z1 -dz;
          glBegin(GL_lines);
          glvertex3f(x,y,z);
          glvertex3f(x1,y1,z1);

          glend();
          if bothsides then
            begin
              glBegin(GL_lines);
              glvertex3f(x,-y,z);
              glvertex3f(x1,-y1,z1);
              glend();
            end;
        end;
    end;
  for i := 0 to frames-1  do
    begin
      for j := 0 to splineform.getverticalpoints -1  do
        begin
          splineform.indexedintermediatepoint(mynode,side,i*splinedots,j,x,y,z);
          splineform.indexedintermediatepoint(mynode,side,i*splinedots,j+1,x1,y1,z1);
          y := -y;
          y1 := -y1;
          x := x - dx;
          y := y -dy;
          z := z -dz;
          x1 := x1 - dx;
          y1 := y1 -dy;
          z1 := z1 -dz;
          glBegin(GL_lines);
          if (i = pred(selectedframe)) then
            begin
              //glLineWidth(3.0);
              glcolor3f(1.0,1.0,0.0);

            end
          else
            begin
              //glLineWidth(1.0);
              glcolor3f(1.0,1.0,1.0) ;
            end;

          glvertex3f(x,y,z);
          glvertex3f(x1,y1,z1);
          glend();
          if bothsides then
            begin
              glBegin(GL_lines);
              glvertex3f(x,-y,z);
              glvertex3f(x1,-y1,z1);
              glend();
            end;
        end;
    end;
end;

begin
  //glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  if showoutside then
    drawnodes(outside,controlnodes[outside]);
  if showinside then
    drawnodes(inside,controlnodes[inside]);


end;



///////////////////////////////////////
Procedure Tmeshmainform.drawfilledmesh;
///////////////////////////////////////
var
  nx,ny,nz:double;
 // del x1,y1,z1:double;
  dx,dy,dz:double;
  p0,p1,p2,p3:Tmypoint;
  myangle:double;
  p0temp,p1temp,p2temp,p3temp:Tmypoint;
  leftside:boolean;

 // radius0,radius1,radius2,radius2:double;


procedure addvertex(p:Tmypoint);
////////////////////////////////
begin
  glvertex3f(p.x,p.y,p.z);
end;


Procedure drawside(side:integer;nodes:Tcontrolnodes);
/////////////////////////////////////////////////////
var
  i,j:Integer;
  nodecount:integer=0;

procedure setcolor;
var
  currentix,currentiy:integer;
begin
  inc(nodecount);
  if odd(nodecount) then
    begin
      if side=inside then
        glcolor3f(0.9,0.8,0.9)
      else
        glcolor3f(0.9,0.9,0.9);
    end
  else
    begin
      if side=inside then
        glcolor3f(0.7,0.7,0.0)
      else
        glcolor3f(0.7,0.7,0.9);
    end ;

  currentix :=(selectedframe-1)*splinedots-1 ;
  currentiy :=(selectedslice-1)*splinedots -1;
{
  if (((i) div 2  )= (currentix div 2 )) and (((j) div 2 ) = (currentiy div 2))  then
    begin
      if odd(nodecount) then
        glcolor3f(0.9,0.95,0.0)
      else
        glcolor3f(0.7,0.7,0.0);
    end;   }
 { if controlnodes[1].node[i div frames+1,j div slices +1].sealevel then
     glcolor3f(0.0,0.0,0.0) }


end;


begin
    for i := 0 to splineform.gethorizontalpoints-1  do

  begin
         for j := 0 to splineform.getverticalpoints-1  do

      begin
       leftside := false;
        p0:=splineform.indexedintermediatepoint(nodes,side,i,j);
        p3:=splineform.indexedintermediatepoint(nodes,side,i,j+1);
        p1:=splineform.indexedintermediatepoint(nodes,side,i+1,j);
        p2:=splineform.indexedintermediatepoint(nodes,side,i+1,j+1);
        p0.y := -p0.y;
        p1.y := -p1.y;
        p2.y := -p2.y;
        p3.y := -p3.y;
        p0.x := p0.x - dx;
        p0.y := p0.y -dy;
        p0.z := p0.z -dz;
        p1.x := p1.x - dx;
        p1.y := p1.y -dy;
        p1.z := p1.z -dz;
        p2.x := p2.x - dx;
        p2.y := p2.y -dy;
        p2.z := p2.z -dz;
        p3.x := p3.x - dx;
        p3.y := p3.y -dy;
        p3.z := p3.z -dz;
        p0temp := p0;
        p1temp := p1;
        p2temp := p2;
        p3temp := p3;
        meshutilsform.normal(p1,p0,p2,nx,ny,nz);
        glBegin(GL_triangles);
          if side=outside then
            glnormal3f(-nx,-ny,-nz)
         else
            glnormal3f(nx,ny,nz);
         setcolor;
          addvertex(p1);
          //setcolor;
          addvertex(p0);
          addvertex(p2);
        glend();
       meshutilsform.normal(p3,p2,p0,nx,ny,nz);

        glBegin(GL_triangles);
          if side=outside then
            begin
              glnormal3f(-nx,-ny,-nz);
            end
          else
            begin
              glnormal3f(nx,ny,nz);
            end;
          setcolor;
          addvertex(p3);
          //setcolor;
          addvertex(p2);
          addvertex(p0);
        glend();
        if bothsides then
          begin
          leftside := true;
          p0:=p0temp;
          p1:=p1temp;
          p2:=p2temp;
          p3:=p3temp;

          p0.y := -p0temp.y;
          p1.y := -p1temp.y;
          p2.y := -p2temp.y;
          p3.y := -p3temp.y;
          meshutilsform.normal(p0,p1,p2,nx,ny,nz);
          glBegin(GL_triangles);
          if side=outside then
            glnormal3f(-nx,-ny,-nz)
          else
            glnormal3f(nx,ny,nz);
            setcolor;
            addvertex(p0);
            addvertex(p1);
            addvertex(p2);
          glend();
          meshutilsform.normal(p2,p3,p0,nx,ny,nz);

          glBegin(GL_triangles);
          if side=outside then
            begin
              glnormal3f(-nx,-ny,-nz);
            end
          else
            begin
              glnormal3f(nx,ny,nz);
            end;
            setcolor;
            addvertex(p2);
            addvertex(p3);
            addvertex(p0);
          glend();
          end;
      end;
  end;

end;


begin
  getcentre(dx,dy,dz);
  if showoutside then
  drawside(outside,controlnodes[outside]);
  if showinside then
    drawside(inside,controlnodes[inside]);
end;

///////////////////////////////////
procedure Tmeshmainform.refreshall;
///////////////////////////////////
begin
  gltopviewform.refreshself;
  glfrontviewform.refreshself;
  glsideviewform.refreshself;
  openglcontrol1.Invalidate;
end;

///////////////////////////////////
procedure Tmeshmainform.refreshall(firstview:integer);
///////////////////////////////////
begin
  case firstview of
    topview:begin gltopviewform.openglcontrol1.paint;glfrontviewform.openglcontrol1.Invalidate;
           glsideviewform.openglcontrol1.Invalidate;end;
    sideview:begin glsideviewform.openglcontrol1.paint;glfrontviewform.openglcontrol1.Invalidate;
           gltopviewform.openglcontrol1.Invalidate;end;
    frontview:begin glfrontviewform.openglcontrol1.paint;gltopviewform.openglcontrol1.Invalidate;
           glsideviewform.openglcontrol1.Invalidate;end;
    end;
  openglcontrol1.Invalidate;
end;


////////////////////////////////////////
procedure Tmeshmainform.handlemymessage;
////////////////////////////////////////
begin
  application.HandleMessage;
end;

//////////////////////////////////
procedure Tmeshmainform.cleargoodlist;
//////////////////////////////////
begin
  meshutilsform.cleargoodlist;
end;

////////////////////////////////////////////////////
procedure Tmeshmainform.FormCreate(Sender: TObject);
////////////////////////////////////////////////////
  begin
  goodlist := tlist.create;
  lastrx:= RzTrackBar.position;

  lastry:= RyTrackBar.position;
  lastrz:= RzTrackBar.position;

end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.OpenGLControl1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
///////////////////////////////////////////////////////////////
begin
  //
  if button in [mbleft] then
    begin
      startmovex := x;
      startmovey := y;
      startmoveoffsetx := offsetx;
      startmoveoffsety := offsety;
      leftmouseisdown := True;
    end;
  if button in [mbright] then
    begin
      startrotationx := x;
      startrotationy := y
    end;

end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.OpenGLControl1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
////////////////////////////////////////////////////////////////
begin  //
  if leftmouseisdown then
    begin
      if leftmouseisdown then
      begin
	offsetx := startmoveoffsetx +  (X - startmovex);
	offsety := startmoveoffsety +  (y - startmovey);

      //  offsetx := x - startmovex;
      //  offsety:= y -startmovey;
      end;
    end;

  if ssright in shift then
    begin
      rytrackbar.position := rytrackbar.position +  x - startrotationx;
      //startrotationx := rxtrackbar.position;
      rxtrackbar.position := rxtrackbar.position +  y - startrotationy;

      startrotationy := y
    end;
  openglcontrol1.Invalidate;
  //  mouseisdown := false;
end;

//////////////////////////////////////////////////////////////////////////////////
procedure TMeshmainform.OpenGLControl1MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
//////////////////////////////////////////////////////////////////////////////////
begin
  leftmouseisdown := false;
  if wheeldelta > 0 then
    scale := scale*sqrt(1.414)
  else
    scale := scale/sqrt(1.414);
   openglcontrol1.paint;
//  mousemoved := True;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.CacheoffBitBtnClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  usecache:= false;
  refreshall;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.BothSidesMenuItemClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  bothsides := not bothsides;
//  showinside := true;
//  showoutside := true;
  refreshall;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.CacheOnBitBtnClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  usecache:= true;
  refreshall;
end;

procedure TMeshmainform.ColorMenuItemClick(Sender: TObject);
begin
  colordialog1.Execute;
end;

procedure TMeshmainform.CreateKeelMenuItemClick(Sender: TObject);
var
  keelwidth:double = 15;
  keeldepth:double=20;
  stemdepth:double=10;
  sternpostdepth:double=0;

  frame,slice:integer;
begin
  //split the whole ship
  // and remove sety=0
  for frame:= 1 to frames do
    begin
      for slice := 1 to slices do
        begin
          controlnodes[outside].node[frame,slice].y:= controlnodes[outside].node[frame,slice].y+keelwidth;
          controlnodes[outside].node[frame,slice].sety0:=false;
        end;
    end;
//
  for frame:= 1 to frames do
    begin
      // lowest slice set y to keelwidth in case of any oddities
      slice:= slices; // for slice := slices to slices do
        begin
          controlnodes[outside].node[frame,slice].y:= keelwidth;
          controlnodes[outside].node[frame,slice].sety0:=false;
        end;
    end;
 inc(slices);  // fill in the down bit of the keel
  for frame:= 1 to frames do
    begin
      for slice := slices to slices do
        begin
          // copy anything from original slice
          controlnodes[outside].node[frame,slice]:=
            controlnodes[outside].node[frame,slice-1];
          // increase depth (z is +ve going up)
          controlnodes[outside].node[frame,slice].z :=
            controlnodes[outside].node[frame,slice-1].z-keeldepth;
          // set creases
          controlnodes[outside].node[frame,slice-1].horizontalcrease:=true;
          controlnodes[outside].node[frame,slice].horizontalcrease:=true;

        end;
    end;
  inc(slices);  // seal up the keel
   for frame:= 1 to frames do
     begin
       slice := slices; //for slice := slices to slices do
         begin
           // copy any creases
           controlnodes[outside].node[frame,slice]:=
             controlnodes[outside].node[frame,slice-1];
           // set centre y= zero
           controlnodes[outside].node[frame,slice].y :=0;
         ///    controlnodes[outside].node[frame,slice-1].y-keelwidth;
           //add creases
           controlnodes[outside].node[frame,slice-1].horizontalcrease:=true;
           controlnodes[outside].node[frame,slice].horizontalcrease:=true;
         // do  sety=0
           controlnodes[outside].node[frame,slice].sety0 :=true;

         end;
     end;


///////////// stem //////////////////////
// create a free frame at the front
   inc(frames);    //<<<
 // we want new frame at the front (frame 1)
  for frame := frames-1 downto 1 do
    begin
      for slice := 1 to slices do
        begin
          // copy frame towards the rear and new frame
          controlnodes[outside].node[frame+1,slice]:=
             controlnodes[outside].node[frame,slice];
        end;
    end;

  inc(frames);  //<<< AGAIN
// we want new frame at the front (frame 1)
// copy frames towards the back
 for frame := frames-1 downto 1 do
   begin
    // copy frame towards the rear and new frame AGAIN!

     for slice := 1 to slices do
       begin
         controlnodes[outside].node[frame+1,slice]:=
            controlnodes[outside].node[frame,slice];
       end;
   end;
 // we have two 'free' slices at the front

  for frame := 1 to 1 do
    begin
      for slice := 1 to slices do
        begin
          // set crease and remove groups
          controlnodes[outside].node[1,slice].foreaftcrease:=true;
          controlnodes[outside].node[2,slice].foreaftcrease:=true;
          controlnodes[outside].node[1,slice].horizontalcrease:=false;
          controlnodes[outside].node[2,slice].horizontalcrease:=false;

          controlnodes[outside].node[3,slice].foreaftcrease:=true;
          controlnodes[outside].node[1,slice].group:=0;
          controlnodes[outside].node[2,slice].group:=0;
          controlnodes[outside].node[3,slice].group:=0;
          //second frame in we ant to project forwards
          controlnodes[outside].node[2,slice].x:=
          controlnodes[outside].node[2,slice].x+stemdepth;
          // frame at nose wants to be projected forwards AN closed to y=0
          controlnodes[outside].node[1,slice].x:=
          controlnodes[outside].node[1,slice].x+stemdepth;
          controlnodes[outside].node[1,slice].y:= 0;
          controlnodes[outside].node[1,slice].sety0:=true;

        end;
    end;
  // tidy up join at the bottom
  //lowest slice joins to centre lowered keel
  controlnodes[outside].node[1,slices].z:=   controlnodes[outside].node[3,slices].z;
  controlnodes[outside].node[2,slices].z:=   controlnodes[outside].node[3,slices].z;
  //next slice up joins to outside of lowered keel
  controlnodes[outside].node[2,slices-1].z:=   controlnodes[outside].node[3,slices-1].z;
  controlnodes[outside].node[2,slices-2].z:=   controlnodes[outside].node[3,slices-1].z;
  //??
  controlnodes[outside].node[2,slices-1].x:=   controlnodes[outside].node[3,slices-1].x;
  controlnodes[outside].node[2,slices-2].x:=   controlnodes[outside].node[3,slices-1].x;

  controlnodes[outside].node[2,slices].x:=   controlnodes[outside].node[3,slices-1].x;
  controlnodes[outside].node[2,slices].x:=   controlnodes[outside].node[3,slices-1].x;


  //2 slices up joins to crease created by lowered keel
  controlnodes[outside].node[1,slices-1].z:=   controlnodes[outside].node[3,slices-1].z;
  controlnodes[outside].node[1,slices-2].z:=   controlnodes[outside].node[3,slices-1].z;
  //??
  controlnodes[outside].node[1,slices-1].x:=   controlnodes[outside].node[3,slices-1].x;
  controlnodes[outside].node[1,slices-2].x:=   controlnodes[outside].node[3,slices-1].x;

  controlnodes[outside].node[1,slices].x:=   controlnodes[outside].node[3,slices-1].x;
  controlnodes[outside].node[1,slices].x:=   controlnodes[outside].node[3,slices-1].x;

  If sternpostdepth = 0 then
  // simply close up the gap created by moving the sides apart
    begin
      inc(frames);
      for slice := 1 to slices do
        begin
          controlnodes[outside].node[frames,slice]:=controlnodes[outside].node[frames-1,slice];
          controlnodes[outside].node[frames,slice].x := controlnodes[outside].node[frames-1,slice].x-10;

          controlnodes[outside].node[frames,slice].y := 0;
        end;


    end;


 splineform.clearcache;

 refreshall;
end;

//-------------------------------------------------------------//
procedure TMeshmainform.CreateStlMenuItemClick(Sender: TObject);
// munuitem
//-------------------------------------------------------------//
begin
   createstl(1,7,1,1);
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.DrawplankMenuItemClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  hidedrawing := false;
  wireframe := false;
  filledmesh := false;
  plank := true;
  refreshall;

end;

////////////////////////////////////////////////////////////////////
procedure TMeshmainform.ExportpartialMenuItemClick(Sender: TObject);
////////////////////////////////////////////////////////////////////
begin
  if partialexportform.ShowModal <> mrok then
    exit;
 // createpartialstl;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.ExportSTLMenuItemClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
    bothsides := true;
   stlexport;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.FaceMenuItemClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  face3dform.show;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.FormDestroy(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  cleargoodlist;
 // goodlist.clear;
  goodlist.free;
end;

//////////////////////////////////////////////////
procedure TMeshmainform.FormShow(Sender: TObject);
//////////////////////////////////////////////////
begin
  infoform.show;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.FrontViewMenuItemClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  glfrontviewform.Show;
end;


////////////////////////////////////////////////////////////////
procedure TMeshmainform.IsoBitBtnClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  rxtrackbar.position := 162;
  rytrackbar.position := 125;
  rztrackbar.position := 145;

  refreshall;
end;

procedure TMeshmainform.LoadAnyMenuItemClick(Sender: TObject);
begin
  if openDialog1.Execute then
    begin
      scale := 1;
    offsety := 0;
    offsetx := 0;
    frames := 1;
    slices := 1;

      currentfilename := openDialog1.Filename;
      databaseform.loadnodesfromfile(currentfilename);
    end;
  refreshall;
end;

procedure TMeshmainform.MenuItem2Click(Sender: TObject);
begin
  createstl(3,7,1,2);
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.RX1TrackBarChange(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  trackbarupdate;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.rxtrackbarChange(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  trackbarupdate;
end;

procedure TMeshmainform.SaveanyMenuItemClick(Sender: TObject);
begin
   SaveDialog1.filename:= currentfilename;
   if SaveDialog1.Execute then
       databaseform.savenodestofile(SaveDialog1.Filename);
end;

procedure TMeshmainform.SaveenvironmentClick(Sender: TObject);
begin
//  FUNCTION writeparm(parmname,parmvalue:String):boolean;
//  FUNCTION readparm(parmname,defaultvalue:String):string;
  meshutilsform.writeparm('topviewplanoffsetx',floattostr(gltopviewform.planoffsetx));
  meshutilsform.writeparm('topviewplanoffsety',floattostr(gltopviewform.planoffsety));
  meshutilsform.writeparm('sideviewplanoffsetx',floattostr(glsideviewform.planoffsetx));
  meshutilsform.writeparm('sideviewplanoffsety',floattostr(glsideviewform.planoffsety));

  meshutilsform.writeparm('screencolor',floattostr(screencolor));



end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.TailIsoBitBtnClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  rxtrackbar.position := 152;
  rytrackbar.position := 184;
  rztrackbar.position := 231;

  refreshall;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.MenuItem1Click(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  splineform.show;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.Face3dWork(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
   face3dform.show;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.MenuItem2to3dClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  TwotothreeDForm.show;
end;

////////////////////////////////////////////////////////////////
procedure TMeshmainform.MenuItemPortholesClick(Sender: TObject);
////////////////////////////////////////////////////////////////
begin
  portholeform.show;
end;

///////////////////////////////////////////////////////////////////
procedure TMeshmainform.ShowInandOutMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////////////
begin
  showinside := true;
  showoutside := true;
  refreshall;
end;

//////////////////////////////////////////////////////////////////
procedure TMeshmainform.ShowInsideMenuItem1Click(Sender: TObject);
//////////////////////////////////////////////////////////////////
begin
  showoutside := false;
  showinside := true;
  refreshall;
end;

////////////////////////////////////////////////////////
procedure TMeshmainform.MenuItem3Click(Sender: TObject);
////////////////////////////////////////////////////////
begin
  MeshUtilsform.show;
end;

////////////////////////////////////////////////////////
procedure TMeshmainform.MenuItem4Click(Sender: TObject);
////////////////////////////////////////////////////////
begin
  createinside;
  showinside := true;
  refreshall;
end;

procedure TMeshmainform.RockmenuitemClick(Sender: TObject);
begin
  rock := not rock;
end;

/////////////////////////////////////////////////////////////
procedure TMeshmainform.SealevelButtonClick(Sender: TObject);
/////////////////////////////////////////////////////////////
var
  i,j:Integer;
begin
  sealevel := -100;
  for i := 1 to frames do
  for j := 1 to slices-1 do
    begin
      if (controlnodes[1].node[i,j].z >= sealevel)
      and (controlnodes[1].node[i,j+1].z < sealevel)
        then
          controlnodes[1].node[i,j].sealevel:= true
        else
          controlnodes[1].node[i,j].sealevel:= false;
    end;
end;

//////////////////////////////////////////////////////////////////
procedure TMeshmainform.InformationMenuItemClick(Sender: TObject);
//////////////////////////////////////////////////////////////////
begin
  if infoform.Showing then
    infoform.hide
  else
    infoform.show;

end;

///////////////////////////////////////////////////////////
procedure TMeshmainform.LoadMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////
begin
  scale := 1;
  offsety := 0;
  offsetx := 0;
  frames := 1;
  slices := 1;
  currentfilename := 'testnodes.txt';
  databaseform.loadnodesfromfile(currentfilename);
  refreshall;
end;

///////////////////////////////////////////////////////////////
procedure TMeshmainform.ClearSTLMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////////
begin
  cleargoodlist;
end;

/////////////////////////////////////
procedure TMeshmainform.CreateInside;
/////////////////////////////////////
var
  i,j,  frame: integer;
  x, y: double;
  x1, y1, x2, y2, x3, y3,x4,y4:double;
  p1,q1,p2,q2:double;
   a1,b1,a2,b2:double;
  dx,dz:double;
  thickness:double;


function keelslot(frame:Integer):double;
begin
//  result := controlnodes[outside].node[frame, slices].y;
  // disable
  result := 0;
end;

begin
  thickness := wallthickness {* scale};
  controlnodes[2] := controlnodes[1];
  //ensure closed at bottom
  currentside:=outside;
  //move frames in using tangents
  // top slice
// increase thickness first
 { for i := 1 to frames do
    for j := 1 to slices do
      begin
        controlnodes[currentside].node[i, j].y :=
          controlnodes[currentside].node[i, j].y + thickness/2;

      end;
  }
// ensure outside is sealed
  for i :=  1 to frames do //1 to frames do
     begin
        for j:= 1 to slices do
          begin
             if controlnodes[outside].node[i, j].sety0 then
               begin
                 controlnodes[inside].node[i, j].y := 0;
                 if (i=1) or (i=frames) or (j=slices) then
                   controlnodes[inside].node[i, j].y := 0;
               end;

          end;
     end;
 // with increased thickness we can start at 1 ??
  for i :=  1 to frames -1 do //1 to frames do

//  for i :=  2 to frames -1 do //1 to frames do
    begin
          j:= 1;
          p1 := controlnodes[currentside].node[i, j].y;
          q1 := controlnodes[currentside].node[i, j].z;
          p2 := controlnodes[currentside].node[i, j+1].y;
          q2 := controlnodes[currentside].node[i, j+1].z;
          meshutilsform.tangents(thickness,p1,q1,p2,q2,a1,b1,{points on y,z}a2,b2);

          if a1 < keelslot(i) then
              a1:= keelslot(i);
          controlnodes[inside].node[i, j].y:=a1;
          controlnodes[inside].node[i, j].z:=b1;

          j:= slices;
          p1 := controlnodes[currentside].node[i, j-1].y;
          q1 := controlnodes[currentside].node[i, j-1].z;
          p2 := controlnodes[currentside].node[i, j].y;
          q2 := controlnodes[currentside].node[i, j].z;
          meshutilsform.tangents(thickness,p1,q1,p2,q2,a1,b1,{points}a2,b2);
          if a2 < keelslot(i) then
            a2:= keelslot(i);
          controlnodes[inside].node[i, j].y:=a2;
          controlnodes[inside].node[i, j].z:=b2;


          for j := 2 to slices-1 do
//          for j := 2 to slices do

            begin
              p1 := controlnodes[currentside].node[i, j-1].y;
              q1 := controlnodes[currentside].node[i, j-1].z;
              p2 := controlnodes[currentside].node[i, j].y;
              q2 := controlnodes[currentside].node[i, j].z;

              x1 := controlnodes[currentside].node[i, j].y;
              y1 := controlnodes[currentside].node[i, j].z;
              x2 := controlnodes[currentside].node[i, j+1].y;
              y2 := controlnodes[currentside].node[i, j+1].z;
    //procedure tangents({centres}x1,y1,x2,y2:double;{results}var x3,y3,x4,y4:Double);
              meshutilsform.tangents(thickness,p1,q1,p2,q2,a1,b1,a2,b2);

              meshutilsform.tangents(thickness,x1,y1,x2,y2,x3,y3,x4,y4);

              meshutilsform.lineintersection(x3,y3,x4,y4, a2,b2,a1,b1,x,y);
              // check for keel slot on bottom slice
              if x < keelslot(i) then
                begin
                    //x:= keelslot(i);
                    controlnodes[inside].node[i, j].y:=x;
                    { ideally find intersection with y=0 vertical axis }
                    meshutilsform.yaxisintersection(p1,q1,x,y,x,y);
                    controlnodes[inside].node[i, j].y:=x;
                    controlnodes[inside].node[i, j].z:=y;


                end
              else
                begin
                  controlnodes[inside].node[i, j].y:=x;
                  controlnodes[inside].node[i, j].z:=y;
                end
            end;
        end;
  //move back end frames forwards if *next* frame is close
  //
  for i := frames div 2 to frames-1 do
    begin
      for j := 1 to slices do
        begin
           dx := controlnodes[outside].node[i+1, j].x - controlnodes[inside].node[i, j].x ;
           if abs(dx)< thickness then
             controlnodes[inside].node[i, j].x:= controlnodes[outside].node[i+1, j].x  + thickness;
        end;
    end;
  //move back end forward regardless
  i := frames;
    begin
      for j := 1 to slices do
        begin
          controlnodes[inside].node[i, j].x:= controlnodes[outside].node[i, j].x  + thickness;
        end;
    end;
   //front end forwards
    for i := 1 to frames div 2  do
      begin
        for j := 1 to slices do
          begin
             dx := controlnodes[outside].node[i, j].x - controlnodes[inside].node[i+1, j].x ;
             if abs(dx)< thickness then
               controlnodes[inside].node[i+1, j].x:= controlnodes[outside].node[i, j].x  - thickness;
          end;
      end;
    // first frame - move forwards regardless
    i := 1;
      begin
        for j := 1 to slices do
          begin
            controlnodes[inside].node[i, j].x:= controlnodes[outside].node[i, j].x  - thickness;
          end;
      end;
    // move up lower hull
    for i := 1 to frames   do
        begin
          for j := slices div 2 to slices-1 do
            begin
               dz := controlnodes[outside].node[i, j+1].z - controlnodes[inside].node[i, j].z ;
               if abs(dz)< thickness then
                 controlnodes[inside].node[i, j].z:= controlnodes[outside].node[i, j+1].z  + thickness;
            end;
        end;
    // move up lowest slice regardless
    for i := 1 to frames   do
        begin
          j := slices;
            begin
              controlnodes[inside].node[i, j].z:= controlnodes[outside].node[i, j].z  + thickness;
            end;
        end;
 // Increased thickness fouls this up
// ensure sealed at centre
  for i :=  1 to frames do //1 to frames do
    begin
       for j:= 1 to slices do
         begin
            if controlnodes[outside].node[i, j].sety0 then
              begin
                controlnodes[inside].node[i, j].y := 0;
                if (i=1) or (i=frames) or (j=slices) then
                  controlnodes[inside].node[i, j].y := 0;
              end;

         end;
    end;


  // ensure top is level
    for i :=  1 to frames do //1 to frames do
       begin
          for j:= 1 to 1 do
            begin
               controlnodes[inside].node[i, j].z :=  controlnodes[outside].node[i, j].z
            end;
       end;
  // restore outside but keep inside
//we have increased the thickness so seal up outside shell
  splineform.clearcache;
  refreshall;
end;


//////////////////////////////////////////////////////////////
procedure tmeshmainform.createstl(startframe,endframe,
   sealstart,sealend:integer);
//////////////////////////////////////////////////////////////

{0 for no cut ,1 for cover cut, 2 make full face}
type
Tstlcontrolnodes= record
 node:array[1..maxframes, 1..maxslices*2+1] of Tnode;
end;


var
  savedcontrolnodes:array[1..2] of Tcontrolnodes;
  i,j:Integer;
  xyzoffset:Tmypoint;
  keel:double=0;
  myintermediatepoint:Tmypoint;
  myotherintermediatepoint:Tmypoint;
//  startframe,endframe:Integer;
  starthorizontalpoints,endhorizontalpoints:integer;
  minthickness:double=1;



////////Create STL ////////////////////////////////
function adjust(p: tmypoint): tmypoint;  // XYZBitBtnClick
  var
    tempresult: Tmypoint;
  begin
    tempresult.x := xyzscale * (p.x - xyzoffset.x);
    tempresult.y := xyzscale * (p.y - xyzoffset.y);
    tempresult.z := xyzscale * (p.z - xyzoffset.z);
   { if tempresult.y <0 then
      begin
       beep;
       tempresult.y := 0;
      end;
    }
    Result := tempresult;
  end;

////////Create STL ///////////////////////////////////////
function mirroradjust(p: tmypoint): tmypoint; // XYZBitBtnClick
var
  tempresult: Tmypoint;
begin
  tempresult.x := xyzscale * (p.x - xyzoffset.x);
  tempresult.y := xyzscale * (-p.y - xyzoffset.y);
  tempresult.z := xyzscale * (p.z - xyzoffset.z);
{  if tempresult.y >0 then
    begin
     beep;
     tempresult.y := 0;
    end;  }
  Result := tempresult;
end;

function zeroY(p:tmypoint):tmypoint;
begin
  p.y:=0;
  result:= p;
end;

///////createSTL////////
procedure addrectangle(p1, p2, p3, p4: Tmypoint;thickness:double;flip:boolean);

var
  keel:double=0;
begin
  if (p1.y=0) and (p2.y=0) and (p3.y=0) and (p4.y=0) then
    exit;
  meshutilsform.fastaddrectangle(adjust(p1).x, adjust(p1).y, adjust(p1).z,
    adjust(p2).x, adjust(p2).y, adjust(p2).z,
    adjust(p3).x, adjust(p3).y, adjust(p3).z
    , adjust(p4).x, adjust(p4).y, adjust(p4).z,flip);
  if bothsides then
    begin
     meshutilsform.fastaddrectangle(
     adjust(p1).x, mirroradjust(p1).y, adjust(p1).z,
       adjust(p2).x, mirroradjust(p2).y, adjust(p2).z
       , adjust(p3).x, mirroradjust(p3).y, adjust(p3).z,
       adjust(p4).x, mirroradjust(p4).y, adjust(p4).z,
       not flip);
     end;
end;

function starthorizontal:integer;

begin
  result := (startframe- 1) *splinedots;
end;

function endhorizontal:integer;

begin
  result := (endframe- 1) *splinedots;
end;

///////////////////////////////////////////////////////////
///////////////////////// createSTL //////////////////////
// \\
begin
  if startframe in [0,1] then
    begin
    startframe:= 1;
    sealstart:=0;
    end;
  if endframe in [0,frames] then
    begin
     endframe := frames;
     sealend := 0;
    end;

  minthickness := thickness/2;

  cleargoodlist;
  splineform.clearcache;
  usecache := false;

   i := splineform.gethorizontalpoints div 2;
   j := splineform.getverticalpoints div 2;
   xyzoffset := splineform.indexedintermediatepoint(currentside,i, j);
   xyzoffset.y := 0;
  //clear list of triangles
// \\   setLength(samples, 12, 64);
  savedcontrolnodes:= controlnodes;


// ALL
//  increase outside width slightly
// check no narrow gaps in inside sheet
  for i := 1 to frames do
  for j := 1 to slices do
    begin
      controlnodes[outside].node[i,j].y:=controlnodes[outside].node[i,j].y+ minthickness;
      // ensure inside sealed ot bottom
      controlnodes[inside].node[i,slices].y := 0;
      //?? ensure first frame is sealed on the inside
      controlnodes[inside].node[1,j].y := 0;
      // ensure last frame is sealed on the inside
      controlnodes[inside].node[frames,j].y := 0;
      // ensure no narrow gaps in keel zone
      If controlnodes[inside].node[i,j].y <= thickness/2 then
        controlnodes[inside].node[i,j].y:= 0;
    end;

// 11
  if sealstart = 1 then
    begin
     for i := startframe to startframe do
     for j := 1 to slices do
       begin
         controlnodes[inside].node[i,j].x:=controlnodes[outside].node[i,j].x;
       end;
    end;
// 11
  if sealend = 1 then
    begin
     for i := endframe to endframe do
     for j := 1 to slices do
       begin
         controlnodes[inside].node[i,j].x:=controlnodes[outside].node[i,j].x;
       end;
    end;

// 22
  if sealstart = 2 then
  // move front frame back
    begin
     for i := startframe to startframe do
       for j := 1 to frames do
         begin
           if controlnodes[inside].node[i,j].x > controlnodes[inside].node[i,j].x - framethickness then
                 controlnodes[inside].node[i,j].x := controlnodes[inside].node[i,j].x - framethickness
         end;
    end;

// 22
  if sealend = 2 then
 // move back frame forward
    begin
     for i := endframe to endframe do
       for j := 1 to frames do
         begin
           if controlnodes[inside].node[i,j].x < controlnodes[inside].node[i,j].x + framethickness then
                 controlnodes[inside].node[i,j].x := controlnodes[inside].node[i,j].x + framethickness
         end;
    end;

// ALL
  //do the outside skin for all modes
  for i := starthorizontal to endhorizontal -1 do
      begin
        for j := 0 to splineform.getverticalpoints-1 do
          begin
            addrectangle(splineform.indexedintermediatepoint(controlnodes[1],1,i, j),
            splineform.indexedintermediatepoint(controlnodes[1],1,i + 1, j),
            splineform.indexedintermediatepoint(controlnodes[1],1,i + 1, j + 1),
            splineform.indexedintermediatepoint(controlnodes[1],1,i, j + 1),keel,true);
          end;
      end; // add inside skin as calculated

// ALL
//do the inside skin for all modes
  for i := starthorizontal to endhorizontal -1 do
    begin
      for j := 0 to splineform.getverticalpoints-1 do
        begin
          addrectangle(splineform.indexedintermediatepoint(controlnodes[2],2,i, j),
          splineform.indexedintermediatepoint(controlnodes[2],2,i + 1, j),
          splineform.indexedintermediatepoint(controlnodes[2],2,i + 1, j + 1),
          splineform.indexedintermediatepoint(controlnodes[2],2,i, j + 1),keel,false);
        end;
    end; // add inside skin as calculated


// ALL
  // join inside control nodes to outside control nodes at slice = 0
  // all modes

  for i := starthorizontal to endhorizontal -1 do
      begin
         addrectangle(splineform.indexedintermediatepoint(controlnodes[2],2,i, 0),
         splineform.indexedintermediatepoint(controlnodes[2],2,i + 1, 0),
         splineform.indexedintermediatepoint(controlnodes[1],1,i + 1, 0),
         splineform.indexedintermediatepoint(controlnodes[1],1,i, 0),keel,true);
      end; // done join inside control nodes to outside control nodes at slice = 0

// ALL
// now seal up the bottom to zeroy all modes
for i := starthorizontal to endhorizontal -1 do
for j := splineform.getverticalpoints to splineform.getverticalpoints do
    begin
       addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
       zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
       zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i+1,j )),
       splineform.indexedintermediatepoint(controlnodes[outside],outside,i+1,j),keel,false);
    end; // done join inside control nodes to outside control nodes at slice = 0


// 00
//seal top=0  now seal up the front and  back
// should seal all the way down the front
if sealstart= 0 then
  begin
    for i := starthorizontal to starthorizontal  do
    for j := 0 to splineform.getverticalpoints do
        begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1 )),
           splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1),keel,false);
        end; // done join inside control nodes to outside control nodes at slice = 0
  end;

// 00
// mode 0 should seal all the way down the back
if sealend = 0 then
  begin
    for i := endhorizontal to endhorizontal  do
    for j := 0 to splineform.getverticalpoints-1 do
        begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1 )),
           splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1),keel,true);
        end; // done join inside control nodes to outside control nodes at slice = 0
  end;

// 00
if sealstart= 0 then
  begin
// seal up the nasty triangle at front .. we increased the outside width!!!
//for i := 0 to 0 do
    for i := starthorizontal to starthorizontal  do
    for j := 0 to 0 do
        begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j ),
           splineform.indexedintermediatepoint(controlnodes[outside],inside,i,j),keel,true);
        end; // done join inside control nodes to outside control nodes at slice = 0
  end;

// 00
if sealend = 0 then
  begin
    // seal up the nasty triangle at back .. we increased the outside width!!!
    for i := endhorizontal to endhorizontal  do
    for j := 0 to 0 do
        begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j ),
           splineform.indexedintermediatepoint(controlnodes[outside],inside,i,j),keel,false);
        end; // done join inside control nodes to outside control nodes at slice = 0
  end;


// 11
if sealstart=1 then
  begin
   // a bit suspect!
    controlnodes[inside].node[startframe,slices].z := controlnodes[outside].node[startframe,slices].z;
     controlnodes[inside].node[startframe,slices].y := 0;

    for i := starthorizontal to starthorizontal do
      begin
        for j := 0 to splineform.getverticalpoints -1 do
          begin
            addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
            (splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j)),
            splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j+1 ),
            splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1),keel,false);
          end;
      end;
    //nasty triangle
   // join the bottom of the outside to centre and bottom of inside
   for i := starthorizontal to starthorizontal do
     begin
       j := splineform.getverticalpoints;
         begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j),
           splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),   keel,true);
         end;
     end;


  end;

// 11
if sealend=1 then
  begin
    // match bottom of inside to outside
    controlnodes[inside].node[endframe,slices].z := controlnodes[outside].node[endframe,slices].z;

    for i := endhorizontal to endhorizontal do
      begin
        for j := 0 to splineform.getverticalpoints do
          begin
            addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
            (splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j)),
            splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j+1 ),
            splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1),keel,true);
          end;
      end;

    //nasty triangle
   // join the bottom of the outside to centre and bottom of inside
   for i := endhorizontal to endhorizontal do
     begin
       j := splineform.getverticalpoints ;
         begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j),
           splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),   keel,false);
         end;
     end;

  end;

// 22
// seal inside and outside to centreline front mode 2
if sealstart = 2 then
  begin
    for i := starthorizontal to starthorizontal  do
    for j := 0  to splineform.getverticalpoints -1 do
        begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1 )),
           splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1),keel,false);

           addrectangle(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j+1 )),
           splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j+1),keel,true);


        end;
  end;

// 22
// seal inside and outside to centreline back
if sealend = 2 then
  begin
   // create the skin
    for i := endhorizontal to endhorizontal  do
    for j := 0  to splineform.getverticalpoints -1 do
        begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1 )),
           splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j+1),keel,true);

           addrectangle(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j),
           zeroy(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j+1 )),
           splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j+1),keel,false);


        end;
    // (seal bottom=2) fill gap between back layers
    for i := endhorizontal to endhorizontal  do
    for j := 0  to 0  do
        begin
           addrectangle(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j),
           (splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[outside],outside,i,j)),
           zeroy(splineform.indexedintermediatepoint(controlnodes[inside],inside,i,j)),
           keel,false);
         end;
  end;



    controlnodes := savedcontrolnodes;

end;




///////////////////////////////////////////////////////////////
procedure TMeshmainform.SetScaleMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////////
begin
  setscaleform.show;
end;

///////////////////////////////////////////////////////////////////
procedure TMeshmainform.SetwireframeMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////////////
begin
  hidedrawing := false;
  wireframe := true;
  filledmesh := false;
  plank:= false;
  refreshall;
end;

///////////////////////////////////////////////////////////////
procedure TMeshmainform.DrawfullMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////////
begin
  hidedrawing := false;
 // wireframe := false;
  filledmesh := true;
  wireframe := false;
  plank:= false;
  refreshall;
end;

//////////////////////////////////////////////////////////////////
procedure TMeshmainform.HidedrawingMenuItemClick(Sender: TObject);
//////////////////////////////////////////////////////////////////
begin
  hidedrawing := not hidedrawing;
  refreshall;
end;

//////////////////////////////////////////////////////////////
procedure TMeshmainform.OpenGLControl1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
//////////////////////////////////////////////////////////////
begin
  leftmouseisdown := False;
end;

///////////////////////////////////////////////////////////
procedure TMeshmainform.SaveMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////
begin
      databaseform.savenodestofile('testnodes.txt');
end;

/////////////////////////////////////////////////////////////////
procedure TMeshmainform.ShowdatabaseButtonClick(Sender: TObject);
/////////////////////////////////////////////////////////////////
begin
  databaseform.Show;
end;

procedure Tmeshmainform.OpenGLControl1Resize(Sender: TObject);
begin
  if OpenGLControl1.Height <= 0 then
    exit;
  OpenGLControl1.AutoResizeViewport := True;
  // the viewport is automatically resized by the TOpenGLControl
  // you can disable it (OpenGLControl1.AutoResizeViewport:=false)
  // and do something yourself here
end;

////////////////////////////////////////////////////////
procedure TMeshmainform.updatetrackbar(Sender: TObject);
////////////////////////////////////////////////////////
begin
  trackbarupdate;
end;

/////////////////////////////////////////////////////////////
procedure TMeshmainform.RangeTrackBarChange(Sender: TObject);
/////////////////////////////////////////////////////////////
begin
  trackbarupdate;
end;

//////////////////////////////////////////////////////////////////
procedure TMeshmainform.ShowOutsideMenuItemClick(Sender: TObject);
//////////////////////////////////////////////////////////////////
begin
  showoutside := True;
  showinside := false;
  refreshall;

end;

///////////////////////////////////////////////////////////////
procedure TMeshmainform.SideViewMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////////
begin
  glsideviewform.show;
end;

///////////////////////////////////////////////////////////////////
procedure TMeshmainform.createinsideMenuItemClick(Sender: TObject);
///////////////////////////////////////////////////////////////////
begin
end;

//////////////////////////////////////////////////////////////
procedure TMeshmainform.TopViewMenuItemClick(Sender: TObject);
//////////////////////////////////////////////////////////////
begin
  gltopviewform.show;
end;

//////////////////////////////////
procedure TMeshmainform.STLexport;
//////////////////////////////////
var
  outfile: Textfile;

  counter: integer;

procedure prints(s: string);
////////////////////////////
begin
  writeln(outfile, s);
end;



Function findstart:Boolean;
///////////////////////////
  var
    s:string;
  begin
    result := false;
    repeat
    s := chr(trunc(meshutilsform.readitem(counter)));
    inc(counter)
    until (s='T') or (counter >= (meshutilsform.itemcount -1));
    if s= 'T' then
      result := true;
  end;

function read:String;
/////////////////////
var
  tempstr:String;
begin
  tempstr := floattostr(meshutilsform.readitem(counter));
  if tempstr='0' then
    tempstr := '0.0';
  result := tempstr;
  if counter < meshutilsform.itemcount -1 then
    inc(counter);
end;


begin
  assignfile(outfile, 'test.stl');
  rewrite(outfile);
  memo1.Lines.Clear;
  prints('solid name');
//  databaseform.activatequery(databaseform.generalsqlquery, sql);
  counter := 0;
  while counter < meshutilsform.itemcount -1 do
    begin
      findstart;
        if counter < meshutilsform.itemcount - 5 then
        begin
          prints('facet normal ' + read + ' ' + read  + ' ' +read +' ');
          prints('outer loop');
          prints('vertex ' + read + ' ' + read  + ' ' +read +' ');
          prints('vertex ' + read + ' ' + read  + ' ' +read +' ');
          prints('vertex ' + read + ' ' + read  + ' ' +read +' ');
          prints('endloop');
          prints('endfacet');
        end;
    end;
  prints('endsolid name');
  closefile(outfile);
end;

//////////////////////////////////////////////////////////
procedure TMeshmainform.RyTrackBarChange(Sender: TObject);
//////////////////////////////////////////////////////////
begin
  trackbarupdate;
end;

//////////////////////////////////////////////////////////
procedure TMeshmainform.RzTrackBarChange(Sender: TObject);
//////////////////////////////////////////////////////////
begin
    trackbarupdate;

end;



/////////////////////////////////
procedure Tmeshmainform.fastdrawSTL;
/////////////////////////////////
var
  counter:Integer;

function advanceandread:double;
///////////////////////////////
begin
  inc(counter);
  result := meshutilsform.readitem(counter);
 // memo1.lines.add(trianglelist[counter]);
end;

function myread:double;
///////////////////////
begin
    result := meshutilsform.readitem(counter);
 // memo1.lines.add(trianglelist[counter]);
end;


begin
  counter := 0;
  while counter < meshutilsform.itemcount -1 do
    begin
      if trunc(myread) = ord('T') then
        begin
          glBegin(GL_triangles);
          if odd(counter) then
            glcolor3f(0.9,0.9,0.9)
          else
            glcolor3f(0.2,0.8,0.8);
          glnormal3f(advanceandread,advanceandread,advanceandread);
          glvertex3f(advanceandread,advanceandread,advanceandread);
          glvertex3f(advanceandread,advanceandread,advanceandread);
          glvertex3f(advanceandread,advanceandread,advanceandread);
          glend();
          if counter <  (meshutilsform.itemcount -1) then
          inc(counter);
        end;
      if trunc(myread) =ord('L') then
        begin
          glBegin(GL_lines);
           glcolor3f(0.9,0.9,0.9);
          glvertex3f(advanceandread,advanceandread,advanceandread);
          glvertex3f(advanceandread,advanceandread,advanceandread);
          glend();
          if counter <  (meshutilsform.itemcount -1) then
            inc(counter);
        end;
    end;
end;


/////////////////////////////////////////////////////////////
procedure Tmeshmainform.OpenGLControl1Paint(Sender: TObject);
/////////////////////////////////////////////////////////////
var
  scalefactor: double;

procedure testsetup;
///////////////////
begin
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);


    glFrontFace(GL_CW);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_AUTO_NORMAL);
    glEnable(GL_NORMALIZE);

    glMaterialf(GL_FRONT, GL_SHININESS, 0.6*128.0);

    glClearColor(0.5, 0.5, 0.5, 1.0);
    glColor3f(1.0, 1.0, 1.0);
end;

function degreestoradians(degrees:double):double;
////////////////////////////////////////////////
begin
  result := degrees /360* 2*pi;
end;

procedure setupmaterial;
////////////////////////
begin
  glEnable(GL_COLOR_MATERIAL);
  glColorMaterial(GL_FRONT_and_back, GL_AMBIENT_AND_DIFFUSE);
  glMaterialf(GL_FRONT_and_back, GL_SHININESS, 0.9);
 // glMaterialf(GL_BACK, GL_SHININESS, 0.9);

end;



procedure setuplights;
begin
  setupmaterial;

  gldisable(gl_cull_face);
  glEnable(GL_LIGHTING);
  //glLightfv(GL_LIGHT0, GL_DIFFUSE, DiffuseLight);
 // glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, GL_true);

  glEnable(GL_LIGHT0);

  //light both sides
  // GL_LIGHT_MODEL_TWO_SIDE
//  glLightfv(GL_LIGHT1, GL_DIFFUSE, DiffuseLight);
  //light both sides
//  glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
//  glEnable(GL_LIGHT1);
end;

procedure trylighting;

 const
//  DiffuseLight: array[0..3] of GLfloat = (0.8, 0.8, 0.8, 1);

 //color of diffuse light
 DiffuseLight: array[0..3] of GLfloat = (0.5, 0.5, 0.5, 1);

 // color of shine
 specular:array[0..2] of GLfloat = (0.3, 0.3, 0.3);
 //color of ambient
 ambient:array[0..2] of glfloat = (0.4, 0.4, 0.4);


  light0position:array[0..3] of glfloat = (-1.0, -1.0, -100.0, 0);
  light1position:array[0..3] of glfloat = (1, 1.0, 100, 0);

  local_view:array[0..0] of  glfloat = (0.0);


begin
  glenable(gl_cull_face);

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, light0position);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, DiffuseLight);

  glEnable(GL_LIGHT1);
  glLightfv(GL_LIGHT1, GL_POSITION, light1position);
  glLightfv(GL_LIGHT1, GL_DIFFUSE, DiffuseLight);



 //  glLightModelfv(GL_LIGHT_MODEL_LOCAL_VIEWER, local_view);

 glEnable(GL_COLOR_MATERIAL);

 // glMaterialf(GL_FRONT, GL_SHININESS, 100);


  glColorMaterial(GL_FRONT_and_back, GL_AMBIENT_AND_DIFFUSE);

  //how bright in ambient
  glMaterialf(GL_FRONT, GL_SHININESS, 0.9*128.0);
  // mirror
  glMaterialfv(GL_FRONT, GL_SPECULAR, specular);

  glLightfv(GL_LIGHT0, GL_DIFFUSE, DiffuseLight);


glClearColor(background[0],background[1],background[2],1);
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
glEnable(GL_DEPTH_TEST);
glClear(GL_COLOR_BUFFER_BIT);

end;



begin   // openglcontrolpaint
  if wireframe then
    begin
      glEnable(GL_DEPTH_TEST);
      glClearColor(background[0],background[1],background[2],background[3]);
      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
      glClear(GL_COLOR_BUFFER_BIT);
    end
  else

  trylighting;
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glPointSize(3.0);
  glEnable(GL_DEPTH_TEST);

  scalefactor :=  10 / (10 + rangeslider);
//  glortho(-openglcontrol1.Width * scalefactor, openglcontrol1.Width * scalefactor
//    , -openglcontrol1.Height * scalefactor, openglcontrol1.Height * scalefactor, -1000, 1000);
  glortho(-openglcontrol1.Width/2, openglcontrol1.Width/2
    , -openglcontrol1.Height/2, openglcontrol1.Height/2, -100000, 100000);

  glmatrixmode(gl_modelview);
  glLoadIdentity();

/////////////////////////////////////////////////
{  glTranslatef(offsetx , -offsety , -20);
  glscalef(scale,scale,0); }
// either works
  glscalef(scale,scale,-1);
  glTranslatef(offsetx/scale , -offsety/scale , 0);

  glRotatef(qaxisrotation.a*360/(2*pi),qaxisrotation.b,qaxisrotation.c,qaxisrotation.d);
  glColor3f(0.0, 0.75, 0.75);

//////////////////////////////////////////////////


//  glTranslatef(700, 0,0);



//  glRotatef(qaxisrotation.a*360/(2*pi),qaxisrotation.b,qaxisrotation.c,qaxisrotation.d);

 // drawthing;
 // glCallList(LIST_OBJECT);
  if not hidedrawing then
    begin
      if filledmesh then
        begin
//          glPolygonMode(GL_FRONT_AND_BACK, GL_fill);
          glPolygonMode(GL_FRONT_AND_back, GL_fill);

          glDisable(GL_CULL_FACE);

        drawfilledmesh;
  //      glLineWidth(4.0);
           //drawmesh;
        end;
    if wireframe then
      begin
       // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        glLineWidth(2.0);
           drawmesh;

      end;
      if plank then
        begin
          glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
          glLineWidth(1.0);
          drawplanked;

        end;
    end;

// draws STL from list to save recalculation
  fastdrawSTL;

  OpenGLControl1.SwapBuffers;

end;


end.

