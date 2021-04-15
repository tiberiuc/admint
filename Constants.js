import Empty from "./img/empty.png";
import Infantry from "./img/infantry.png";
import Archers from "./img/archers.png";
import IronGuards from "./img/iron_guards.png";
import Bomber from "./img/bomber.png";
import Catapult from "./img/catapult.png";
import HellJailers from "./img/hell_jailers.png";
import FireMage from "./img/fire_mage.png";
import Bandits from "./img/bandits.png";
import OgreWarrior from "./img/ogre_warrior.png";
import GhostAssassins from "./img/ghost_assassins.png";
import MagicApprentice from "./img/magic_apprentice.png";
import VikingWarrior from "./img/viking_warrior.png";
import IceMage from "./img/ice_mage.png";
import Scholar from "./img/scholar.png";
import Inquisitor from "./img/inquisitor.png";
import UndeadSoldier from "./img/undead_soldier.png";
import HarbingerOfFire from "./img/harbinger_of_fire.png";
import Paladin from "./img/paladin.png";
import Balista from "./img/balista.png";
import Gobikazes from "./img/gobikazes.png";
import Cactuses from "./img/cactuses.png";
import Necromancer from "./img/necromancer.png";
import Pilgrims from "./img/pilgrims.png";
import Yasha from "./img/yasha.png";
import PriestMage from "./img/priest_mage.png";
import TaurusWitcher from "./img/taurus_witcher.png";
import VoodooDolls from "./img/voodoo_dolls.png";
import PumpkinGuard from "./img/pumpkin_guard.png";
import DarkWitch from "./img/dark_witch.png";
import Nun from "./img/nun.png";
import Daemon from "./img/daemon.png";
import BeastMaster from "./img/beast_master.png";
import FrostArchers from "./img/frost_archers.png";
import WhitchcraftTotem from "./img/whitchcraft_totem.png";
import MeteorGolem from "./img/meteor_golem.png";
import SacredSwordsman from "./img/sacred_swordsman.png";
import StoneGolem from "./img/stone_golem.png";
import PirateShip from "./img/pirate_ship.png";
import RhinoKnight from "./img/rhino_knight.png";
import Pharaoh from "./img/pharaoh.png";

export const DefaultTroopConfig = {
  name: "",
  img: Empty,
  type: "troop",
};

export const DefaultTroopData = {
  lvl: 0,
  troopId: 0,
};

export const TroopsData = {
  0: DefaultTroopConfig,
  inf: { type: "troop", name: "Infantry", img: Infantry },
  ar: { type: "troop", name: "Archers", img: Archers },
  ig: { type: "troop", name: "Iron Guards", img: IronGuards },
  bo: { type: "troop", name: "Bomber", img: Bomber },
  cat: { type: "troop", name: "Catapult", img: Catapult },
  hj: { type: "troop", name: "Hell Jailers", img: HellJailers },
  fm: { type: "troop", name: "Fire Mage", img: FireMage },
  ban: { type: "troop", name: "Bandits", img: Bandits },
  ow: { type: "troop", name: "Ogre Warrior", img: OgreWarrior },
  ga: { type: "troop", name: "Ghost Assassins", img: GhostAssassins },
  ma: { type: "troop", name: "Magic Apprentice", img: MagicApprentice },
  vw: { type: "troop", name: "Viking Warrior", img: VikingWarrior },
  im: { type: "troop", name: "Ice Mage", img: IceMage },
  sc: { type: "troop", name: "Scholar", img: Scholar },
  inq: { type: "troop", name: "Inquisitor", img: Inquisitor },
  us: { type: "troop", name: "Undead Soldier", img: UndeadSoldier },
  hf: { type: "troop", name: "Harbinger of Fire", img: HarbingerOfFire },
  pa: { type: "troop", name: "Paladin", img: Paladin },
  bal: { type: "troop", name: "Balista", img: Balista },
  go: { type: "troop", name: "Gobikazes", img: Gobikazes },
  cac: { type: "troop", name: "Cactuses", img: Cactuses },
  nec: { type: "troop", name: "Necromancer", img: Necromancer },
  pil: { type: "troop", name: "Pilgrims", img: Pilgrims },
  yas: { type: "troop", name: "Yasha", img: Yasha },
  pm: { type: "troop", name: "Priest Mage", img: PriestMage },
  tw: { type: "troop", name: "Taurus Witcher", img: TaurusWitcher },
  vd: { type: "troop", name: "Voodoo Dolls", img: VoodooDolls },
  pg: { type: "troop", name: "Pumkin Guard", img: PumpkinGuard },
  dw: { type: "troop", name: "Dark Witch", img: DarkWitch },
  nun: { type: "troop", name: "Nun", img: Nun },
  dem: { type: "troop", name: "Demon", img: Daemon },
  bm: { type: "troop", name: "Beast Master", img: BeastMaster },
  wt: { type: "troop", name: "Witchcraft Totem", img: WhitchcraftTotem },
  mg: { type: "troop", name: "Metero Golem", img: MeteorGolem },
  fa: { type: "troop", name: "Frost Archers", img: FrostArchers },
  ss: { type: "troop", name: "Sacred Swordsman", img: SacredSwordsman },
  sg: { type: "troop", name: "Stone Golem", img: StoneGolem },
  ps: { type: "troop", name: "Pirate Ship", img: PirateShip },
  rk: { type: "troop", name: "Rhino Knight", img: RhinoKnight },
  ph: { type: "troop", name: "Pharaoh", img: Pharaoh },
};
