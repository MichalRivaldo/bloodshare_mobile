'use strict';

/**
 * Aturan kompatibilitas donor darah.
 * Key: "Golongan|Rhesus" (donor), Value: array of "Golongan|Rhesus" (penerima)
 */
const COMPATIBILITY_MAP = {
  'O|-':  ['O|-', 'O|+', 'A|-', 'A|+', 'B|-', 'B|+', 'AB|-', 'AB|+'],
  'O|+':  ['O|+', 'A|+', 'B|+', 'AB|+'],
  'A|-':  ['A|-', 'A|+', 'AB|-', 'AB|+'],
  'A|+':  ['A|+', 'AB|+'],
  'B|-':  ['B|-', 'B|+', 'AB|-', 'AB|+'],
  'B|+':  ['B|+', 'AB|+'],
  'AB|-': ['AB|-', 'AB|+'],
  'AB|+': ['AB|+'],
};

/**
 * Return array of "Golongan|Rhesus" string yang bisa menerima darah dari donor ini.
 * @param {string} donorGolongan - 'O' | 'A' | 'B' | 'AB'
 * @param {string} donorRhesus   - '+' | '-'
 * @returns {Array<{golongan: string, rhesus: string}>}
 */
function getCompatibleRecipients(donorGolongan, donorRhesus) {
  const key = `${donorGolongan}|${donorRhesus}`;
  const recipients = COMPATIBILITY_MAP[key] || [];
  return recipients.map((r) => {
    const [golongan, rhesus] = r.split('|');
    return { golongan, rhesus };
  });
}

/**
 * Cek apakah donor bisa mendonor ke penerima tertentu.
 * @param {string} donorGolongan
 * @param {string} donorRhesus
 * @param {string} recipientGolongan
 * @param {string} recipientRhesus
 * @returns {boolean}
 */
function canDonate(donorGolongan, donorRhesus, recipientGolongan, recipientRhesus) {
  const donorKey = `${donorGolongan}|${donorRhesus}`;
  const recipientKey = `${recipientGolongan}|${recipientRhesus}`;
  const recipients = COMPATIBILITY_MAP[donorKey] || [];
  return recipients.includes(recipientKey);
}

/**
 * Cari golongan donor yang kompatibel dengan penerima tertentu.
 * @param {string} recipientGolongan
 * @param {string} recipientRhesus
 * @returns {Array<{golongan: string, rhesus: string}>}
 */
function getCompatibleDonors(recipientGolongan, recipientRhesus) {
  const recipientKey = `${recipientGolongan}|${recipientRhesus}`;
  const donors = [];
  for (const [donorKey, recipientList] of Object.entries(COMPATIBILITY_MAP)) {
    if (recipientList.includes(recipientKey)) {
      const [golongan, rhesus] = donorKey.split('|');
      donors.push({ golongan, rhesus });
    }
  }
  return donors;
}

module.exports = { getCompatibleRecipients, canDonate, getCompatibleDonors };
