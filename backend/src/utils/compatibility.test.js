'use strict';

const {
  getCompatibleRecipients,
  canDonate,
  getCompatibleDonors,
} = require('./compatibility');

describe('getCompatibleRecipients', () => {
  test('O- bisa donasi ke semua golongan', () => {
    const recipients = getCompatibleRecipients('O', '-');
    const keys = recipients.map((r) => `${r.golongan}|${r.rhesus}`);
    expect(keys).toContain('O|-');
    expect(keys).toContain('O|+');
    expect(keys).toContain('A|-');
    expect(keys).toContain('A|+');
    expect(keys).toContain('B|-');
    expect(keys).toContain('B|+');
    expect(keys).toContain('AB|-');
    expect(keys).toContain('AB|+');
    expect(recipients).toHaveLength(8);
  });

  test('AB+ hanya bisa donasi ke AB+', () => {
    const recipients = getCompatibleRecipients('AB', '+');
    expect(recipients).toHaveLength(1);
    expect(recipients[0]).toEqual({ golongan: 'AB', rhesus: '+' });
  });
});

describe('canDonate', () => {
  test('A+ ke AB+ valid', () => {
    expect(canDonate('A', '+', 'AB', '+')).toBe(true);
  });

  test('A+ ke B+ invalid', () => {
    expect(canDonate('A', '+', 'B', '+')).toBe(false);
  });

  test('O- ke semua valid', () => {
    expect(canDonate('O', '-', 'O', '-')).toBe(true);
    expect(canDonate('O', '-', 'AB', '+')).toBe(true);
    expect(canDonate('O', '-', 'B', '-')).toBe(true);
  });

  test('AB+ ke O- invalid', () => {
    expect(canDonate('AB', '+', 'O', '-')).toBe(false);
  });
});

describe('getCompatibleDonors', () => {
  test('getCompatibleDonors(AB, +) mengembalikan semua golongan', () => {
    const donors = getCompatibleDonors('AB', '+');
    const keys = donors.map((d) => `${d.golongan}|${d.rhesus}`);
    // AB+ bisa menerima dari semua golongan
    expect(keys).toContain('O|-');
    expect(keys).toContain('O|+');
    expect(keys).toContain('A|-');
    expect(keys).toContain('A|+');
    expect(keys).toContain('B|-');
    expect(keys).toContain('B|+');
    expect(keys).toContain('AB|-');
    expect(keys).toContain('AB|+');
    expect(donors).toHaveLength(8);
  });

  test('getCompatibleDonors(O, -) mengembalikan hanya O-', () => {
    const donors = getCompatibleDonors('O', '-');
    expect(donors).toHaveLength(1);
    expect(donors[0]).toEqual({ golongan: 'O', rhesus: '-' });
  });
});
