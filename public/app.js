var app = new Vue({
  el: '#app',
  data: {
    day: 1,
    page: "departments",
    waiting: true,
  },

  methods: {
    next_day: function () {
      app.waiting = true;
      ws.send('d');
    },
    reset: function () {
      app.waiting = true;
      ws.send('r');
    },
  },

  computed: {
  },
});

const ws = new WebSocket('ws://localhost:3000/ws');

ws.onopen = event => {
  // alert('onopen');
  // ws.send("Hello Web Socket!");
};

ws.onerror = event => {
  // alert(event.data);
};

ws.onmessage = event => {
  all = JSON.parse(event.data);
  app.day = all.day;
  app.waiting = false;
};

