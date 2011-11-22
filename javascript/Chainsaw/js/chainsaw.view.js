var ChainsawView = function(canvasEl){
  this.canvasEl = canvasEl;
  // console.log(" - View loaded");

  this.width = 550;
  this.height = 350;
  this.paper = Raphael(canvasEl[0], this.width, this.height);

  document.onselectstart = function () { return false; };

  this.buttons = {
    start: $('#startButton').click(function(){
      this.startGame();
    }.bind(this)),

    stop: $('#stopButton').click(function(){
      this.endGame();
    }.bind(this)),

    mute: $('#mute').click(function(){
      this.audio.toggleMute();
    }.bind(this)),
    
    selectLevel: $('#levelselect input[type=button]').click(function(e){
      this.levelSelected(e.target.dataset.level);
    }.bind(this)),

    continue: $("#results #continue").click(function(e){
      this.dialogs.results.fadeOut(200);
      this.dialogs.levelSelect.show();

    }.bind(this))

  }

  this.dialogs = {
    levelSelect: $("#levelselect"),
    results: $('#results')
  }

  this.labels = {
    nametag: $("#username"),
    levelLabel: null,
    cutBeginArrow: null,
    cutDownArrow: null,
    cutEdges: this.paper.set(), // The "cut edge -" labels on either side
    playerInput: $('#playername'),
    piecesaccepted: $('#piecesaccepted'),
    piecestotal: $('#piecestotal'),
    piecespercent: $('#piecespercent'),
    fuelTank: $('#fuel #tank #contents')
  }

  this.audio = {
    el: null,
    volume: $('#volume').change(function(){
      this.audio.el.volume = this.audio.volume[0].value;
    }.bind(this)),

    toggleMute: function(){
      if(this.muted){
        this.volume[0].value = 1;
        this.volume.trigger('change');
        this.muted = false;
      }else{
        this.volume[0].value = 0;
        this.volume.trigger('change');
        this.muted = true;
      }
    },
    muted: false,
    cutting: 'assets/start.mp3',
    finished: 'assets/stop.mp3',
    play: function(sound){
      if(this.el) this.el.pause();
      this.el = new Audio(sound);
      this.el.volume = this.volume[0].value;
      this.el.play();
    }
  }
  
  // Global event listeners
  _bind('renderLog', function(e, log){ this.renderLog(log) }.bind(this));
  _bind('renderCut', function(e, log, x){ this.renderCut(log, x); }.bind(this));
  _bind('clear', function(){ this.clear(); }.bind(this));
  _bind('endGameView', function(){ this.endGame(); }.bind(this));
  _bind('updateFuel', function(e, fuel){ this.updateFuel(fuel); }.bind(this));
  _bind('updateActiveLog', function(e, oldLog, newLog){ this.updateActiveLog(oldLog, newLog); }.bind(this));
  _bind('drawResultLabel', function(e, x, y, valid){ this.drawResultLabel(x,y,valid); }.bind(this));
  _bind('showResults', function(e, r, w){ this.showResults(r,w); }.bind(this));
  _bind('updateCutPointer', function(e, y, cut){ this.updateCutPointer(y, cut); }.bind(this));

  this.clear();
};



ChainsawView.prototype = {
  clear: function(){
    this.labels.cutDownArrow = null;
    this.labels.cutEdges = this.paper.set();
    this.paper.clear();
    this.svgLogs = this.paper.set();
    this.labels.cutBeginArrow = this.paper.image("assets/cutz/cut_left_above.png", 0, 0, 82, 32).attr({opacity: 0});
  },


  levelSelected: function(level){
    this.clear();
    this.labels.nametag.html(this.labels.playerInput.val() || "Player");
    var niceLevelName = level.replace('practice','Practice').replace('directional','Directional Cut').replace('free','Free Cut');
    this.labels.levelLabel = this.paper.text(this.width/2, this.height-12, niceLevelName).attr({fill: 'black', font: '300 12px Helvetica, arial, sans-serif'});
    this.buttons.start.removeAttr('disabled');
    this.dialogs.levelSelect.fadeOut(100);
    _trigger('levelSelected', level);
  },

  startGame: function(){
    this.buttons.stop.show();
    this.buttons.start.hide();
    this.canvasEl.addClass('active');
    this.audio.play(this.audio.cutting);
    _trigger('startGame', [this.labels.nametag.html()]);

  },

  endGame: function(){
    this.buttons.stop.hide();
    this.buttons.start.attr('disabled', 'disabled').show();
    this.canvasEl.removeClass('active');
    this.audio.play(this.audio.finished);
    _trigger('endGame');
  },

  drawResultLabel: function(x,y,valid){
    if(valid){
      this.paper.text(x, y, "✓")
                .attr({ fill: '#00FF00', 'font-size': 16 });
    }else{
      this.paper.text(x, y, "X")
                .attr({ fill: 'red', 'font-size': 16});
    }
  },

  showResults: function(right, wrong){
    this.labels.piecesaccepted.html(right);
    this.labels.piecestotal.html(right + wrong);
    this.labels.piecespercent.html(right + wrong == 0 ? "0%" : Math.floor(right/(right+wrong) * 100) + "%");
    this.dialogs.results.delay(800).fadeIn(200);
  },

  updateFuel: function(fuel){
    this.labels.fuelTank.height(fuel);
  },

  updateCutPointer: function(y, cut){
    if(!this.labels.cutDownArrow){
      // Create the arrow
      this.labels.cutDownArrow = this.paper.image("assets/Arrow1Flat.png", 0, 0, 20, 33);
    }
    // Reposition
    this.labels.cutDownArrow.attr({ x: cut-10, y: y -33});
    // Remove 'init' arrow
    this.labels.cutBeginArrow.animate({opacity: 0}, 200);
  },

  updateCutEdgeLabels: function(log){
    /*
     * Update legacy 'cut edge' labels on either side of the log. TODO decide if these should be completely removed!
     * If so, some restructuring may be in order - remove from this.labels and rename this function
     *
    this.labels.cutEdges.forEach(function(e){ if(e) e.remove(); });

    var label1 = this.paper.text(0, 0, "cut edge -"),
        label2 = this.paper.text(0, 0, "- cut edge");
    label1.attr({x:log.x-8-(label1.node.clientWidth/2), y:log.y});
    label2.attr({x:log.x+8+log.width+(label2.node.clientWidth/2), y:log.y});

    this.labels.cutEdges.push(label1, label2)
                        .attr({'font-size':12});
    */

    // Initial "Begin cut" label:
    if(this.labels.cutDownArrow){ this.labels.cutDownArrow.hide(); this.labels.cutDownArrow = null; }
    var xPos = log.x - 41,
        yPos = log.y - 32;
    // Move the label to the right side of the log if necessary
    if(log.direction == 'left'){ xPos += log.width; }
    this.labels.cutBeginArrow.attr({x: xPos, y: yPos, src: "assets/cutz/cut_"+log.direction+"_above.png"}).animate({opacity: 1}, 200);

  },

  renderLog: function(log){
    // Paths as defined by the SVG spec - nice and confusing
    // See http://raphaeljs.com/reference.html#Paper.path for a rough idea of what's going on here
    
    // Start the path in the right place  
    var newPath = "M"+log.x+","+log.y;


    /* Draw the top line in segments */
    var segmentCount = Math.floor((1 + Math.random()*1.4)*(log.width/200));
    var averageWidth = Math.floor(log.width/segmentCount);

    var currentPosition = log.x; 
    var lastPosition;
    var endOfLog = false;
    while(!endOfLog) { // add a new segment to our log 
      lastPosition = currentPosition; 
      if(currentPosition + averageWidth + 50 > log.x + log.width){
        currentPosition = log.x + log.width;
        endOfLog = true;
      }else{
        currentPosition = currentPosition + averageWidth + (Math.random() - 0.5)*75;
      }
      newPath += "S"+((currentPosition+lastPosition)/2)+","+(log.y-3)+" "+currentPosition+","+log.y;
    }
    newPath += 'l0,0' // Sharp corners


    /* Draw the right hand side */
    newPath += "S"+(log.x+log.width+5)+","+(log.y+(log.height/2))+" "+(log.x+log.width)+","+(log.y+log.height);
    newPath += 'l0,0' // Sharp corners


    /* Draw the bottom line in segments */
    var currentPosition = log.x+log.width; 
    var lastPosition;
    var endOfLog = false;
    while(!endOfLog) { // add a new segment to our log 
      lastPosition = currentPosition; 
      if(currentPosition - averageWidth - 50 < log.x){
        currentPosition = log.x;
        endOfLog = true;
      }else{
        currentPosition = currentPosition - averageWidth - (Math.random() - 0.5)*75;
      }
      newPath += "S"+((currentPosition+lastPosition)/2)+","+(log.y+log.height+3)+" "+currentPosition+","+(log.y+log.height);
    }
    newPath += 'l0,0' // Sharp corners


    /* Draw the left hand side */
    newPath += "S"+(log.x+5)+","+(log.y+(log.height/2))+" "+log.x+","+log.y;
    newPath += 'l0,0' // Sharp corners

    /* Draw the end of the log */
    logEndPath = "M"+log.x+","+log.y;
    logEndPath += "s-8,0 0,"+log.height+"l0,0";
    logEndPath += "s8,0 0,-"+log.height;



    /* Render shadows */
    var shadow = this.paper.rect(log.x-2, log.y + log.height-5, log.width+4, 13, 10).attr({ fill: 'rgba(0,0,0,0.6)' });
    shadow.blur(3);

    var newLog = this.paper.path(newPath);
    var newLogEnd = this.paper.path(logEndPath);

    this.svgLogs.push(newLogEnd, newLog);

    log.cutSurface = this.paper.rect(log.x, log.y, log.width, 5).attr({ fill: '#764d13' });
    if(!log.active){ log.cutSurface.hide(); }

    this.svgLogs.attr({ fill: "90-#b17603-#bea379", 'stroke-width': 2, stroke: '#764d13' });
  },

  renderCut: function(log, x){
    this.paper.path("M"+x+","+log.y+"s3,0 0,35")
              .attr({ 'stroke-width': 2, stroke: '#764d13'});

  },

  updateActiveLog: function(oldLog, newLog){
    if(oldLog) oldLog.cutSurface.hide();
    newLog.cutSurface.show();
    this.updateCutEdgeLabels(newLog);
  }
}

