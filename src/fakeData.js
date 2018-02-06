
const data = {
  nodes: [
    { id: 'a', startNode: true },
    { id: 'b' },
    { id: 'c' },
    { id: 'd' },
    { id: 'e' },
    { id: 'f' },
    { id: 'g' },
    { id: 'h' },
    { id: 'i' },
    { id: 'j' },
    { id: 'k' },
    { id: 'l' },
    { id: 'm' },
    { id: 'n' },
    { id: 'o' },
  ],
  edges: [
    { source: 'a', target: 'b' },
    { source: 'b', target: 'c' },
    { source: 'b', target: 'd' },
    { source: 'd', target: 'e' },
    { source: 'e', target: 'f' },
    { source: 'f', target: 'g' },
    { source: 'g', target: 'h' },
    { source: 'h', target: 'i' },
    { source: 'i', target: 'j' },
    { source: 'j', target: 'd' },
    { source: 'h', target: 'k' },
    { source: 'h', target: 'l' },
    { source: 'l', target: 'm' },
    { source: 'm', target: 'n' },
    { source: 'n', target: 'o' },

  ],
};

export { data };
